defmodule RendevousHashTest do
  use ExUnit.Case
  doctest RendevousHash

  @e RendevousHash.Elixir
  @n RendevousHash.Native

  test "hash/1 works consistently across Elixir and Rust" do
    hash_input = "Some input string"

    assert @e.hash(hash_input) == @n.hash(hash_input)
  end

  test "pre_compute_list/1 works consistently across Elixir and Rust" do
    inputs = ["bucket1", "bucket2", "bucket3"]

    assert @e.pre_compute_list(inputs) == @n.pre_compute_list(inputs)
  end

  test "list/2 works consistently across Elixir and Rust" do
    bucket_hashes = @n.pre_compute_list(["bucket1", "bucket2", "bucket3"])
    key = "test_key"

    assert @e.list(bucket_hashes, key) == @n.list(bucket_hashes, key)
  end
end
