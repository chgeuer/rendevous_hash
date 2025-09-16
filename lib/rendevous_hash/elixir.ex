defmodule RendevousHash.Elixir do
  @moduledoc """
  Pure Elixir implementation of rendezvous hashing.

  Provides a fallback implementation using Murmur3 hashing and includes
  advanced replica selection algorithms for optimal storage resiliency.
  """
  @behaviour RendevousHash.Behaviour

  import Bitwise

  @impl RendevousHash.Behaviour
  def hash(x) do
    {:ok, hash} = Murmur3.murmur3_x86_32(to_string(x))
    hash
  end

  @max_32_bit 0xFFFF_FFFF

  defp combine_hashes({bucket, bucket_hash}, key_hash) when is_integer(key_hash) do
    combined_hash = bucket_hash * key_hash &&& @max_32_bit
    {bucket, combined_hash}
  end

  @impl RendevousHash.Behaviour
  def pre_compute_list(inputs) do
    Map.new(inputs, &{&1, hash(&1)})
  end

  @impl RendevousHash.Behaviour
  @spec list(map(), binary() | integer()) :: list()
  def list(bucket_hashes, key) when is_binary(key), do: list(bucket_hashes, hash(key))

  def list(bucket_hashes, key_hash) when is_integer(key_hash) do
    bucket_hashes
    |> Enum.map(&combine_hashes(&1, key_hash))
    |> Enum.sort_by(fn {_bucket, hash} -> hash end)
    |> Enum.map(fn {bucket, _hash} -> bucket end)
  end
end
