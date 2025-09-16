defmodule RendevousHash.Native do
  @moduledoc """
  Native Rust implementation of rendezvous hashing using NIFs.

  Provides high-performance hashing operations through Rustler bindings.
  """
  use Rustler, otp_app: :rendevous_hash, crate: "rendevous_hash"
  @behaviour RendevousHash.Behaviour

  defp murmur_hash(_input), do: :erlang.nif_error(:nif_not_loaded)

  defp sorted_bucket_list(_map, _multiplier), do: :erlang.nif_error(:nif_not_loaded)

  @impl RendevousHash.Behaviour
  def hash(x) do
    x |> to_string() |> murmur_hash()
  end

  @impl RendevousHash.Behaviour
  def pre_compute_list(inputs) do
    inputs
    |> Map.new(&{&1, hash(&1)})
  end

  @impl RendevousHash.Behaviour
  def list(bucket_hashes, key) when is_binary(key) do
    list(bucket_hashes, hash(key))
  end

  def list(bucket_hashes, key_hash) when is_integer(key_hash) do
    sorted_bucket_list(bucket_hashes, key_hash)
  end
end
