defmodule RendevousHash.PropertiesTest do
  use ExUnit.Case, async: true
  use PropCheck

  @e RendevousHash.Elixir
  @n RendevousHash.Native

  # -- Generators --

  defp node_list do
    let {prefix, count} <-
         {elements(["node", "server", "bucket", "shard", "replica"]), range(2, 15)} do
      Enum.map(1..count, &"#{prefix}-#{&1}")
    end
  end

  defp key do
    let n <- range(1, 100_000) do
      "key-#{n}"
    end
  end

  defp key_list do
    let count <- range(5, 50) do
      Enum.map(1..count, &"key-#{&1}")
    end
  end

  # -- Properties --

  property "determinism: same inputs always produce the same ranking" do
    forall {nodes, k} <- {node_list(), key()} do
      bucket_hashes = @n.pre_compute_list(nodes)
      result1 = @n.list(bucket_hashes, k)
      result2 = @n.list(bucket_hashes, k)
      result1 == result2
    end
  end

  property "permutation invariance: node insertion order does not affect output" do
    forall {nodes, k} <- {node_list(), key()} do
      hashes_original = @n.pre_compute_list(nodes)
      hashes_reversed = @n.pre_compute_list(Enum.reverse(nodes))
      hashes_sorted = @n.pre_compute_list(Enum.sort(nodes))

      result_original = @n.list(hashes_original, k)
      result_reversed = @n.list(hashes_reversed, k)
      result_sorted = @n.list(hashes_sorted, k)

      result_original == result_reversed and result_original == result_sorted
    end
  end

  property "complete coverage: output is a permutation of the input nodes" do
    forall {nodes, k} <- {node_list(), key()} do
      bucket_hashes = @n.pre_compute_list(nodes)
      result = @n.list(bucket_hashes, k)

      Enum.sort(result) == Enum.sort(nodes)
    end
  end

  property "consistent prefix: top-k is always a prefix of the full ranking" do
    forall {nodes, k} <- {node_list(), key()} do
      bucket_hashes = @n.pre_compute_list(nodes)
      full_list = @n.list(bucket_hashes, k)

      Enum.all?(1..length(nodes), fn n ->
        Enum.take(full_list, n) == RendevousHash.list(bucket_hashes, k, n)
      end)
    end
  end

  property "elixir and rust implementations produce identical results" do
    forall {nodes, k} <- {node_list(), key()} do
      elixir_hashes = @e.pre_compute_list(nodes)
      native_hashes = @n.pre_compute_list(nodes)

      elixir_hashes == native_hashes and
        @e.list(elixir_hashes, k) == @n.list(native_hashes, k)
    end
  end

  property "hash consistency: hashing the same input always returns the same value" do
    forall input <- non_empty(utf8()) do
      @n.hash(input) == @n.hash(input) and
        @e.hash(input) == @e.hash(input) and
        @e.hash(input) == @n.hash(input)
    end
  end

  property "minimal disruption: removing one node only reassigns keys that were mapped to it" do
    forall {nodes, keys} <- {node_list(), key_list()} do
      full_hashes = @n.pre_compute_list(nodes)

      # Pick the last node to remove
      removed = List.last(nodes)
      remaining = List.delete(nodes, removed)

      case remaining do
        [] ->
          true

        _ ->
          reduced_hashes = @n.pre_compute_list(remaining)

          # For each key, check: if the preferred node didn't change,
          # the key wasn't reassigned. If it did change, it must have
          # been assigned to the removed node before.
          Enum.all?(keys, fn k ->
            [original_first | _] = @n.list(full_hashes, k)
            [new_first | _] = @n.list(reduced_hashes, k)

            if original_first == removed do
              # Key was on the removed node, so it must move — that's expected
              true
            else
              # Key was NOT on the removed node, so it must stay put
              original_first == new_first
            end
          end)
      end
    end
  end

  property "relative order preservation: removing a node preserves the relative order of remaining nodes" do
    forall {nodes, k} <- {node_list(), key()} do
      full_hashes = @n.pre_compute_list(nodes)
      full_ranking = @n.list(full_hashes, k)

      removed = List.last(nodes)
      remaining = List.delete(nodes, removed)

      case remaining do
        [] ->
          true

        _ ->
          reduced_hashes = @n.pre_compute_list(remaining)
          reduced_ranking = @n.list(reduced_hashes, k)

          # The reduced ranking should equal the full ranking with the removed node filtered out
          Enum.filter(full_ranking, &(&1 != removed)) == reduced_ranking
      end
    end
  end
end
