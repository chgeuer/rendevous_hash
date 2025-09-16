defmodule RendevousHash.Behaviour do
  @moduledoc """
  A behaviour for implementing Rendevous Hashing in Elixir.
  """

  @type stringable :: String.Chars.t()
  @type node_list :: [stringable()]
  @type precomputed_hashes :: %{stringable() => integer()}

  @doc """
  Computes a hash for the given input.
  """
  @callback hash(input :: integer()) :: integer()

  @doc """
  Pre-computes a list of hashes for the given inputs.

  Inspired by https://www.npiontko.pro/2024/12/23/computation-efficient-rendezvous-hashing
  """
  @callback pre_compute_list(list :: node_list()) :: precomputed_hashes()

  @callback list(params :: precomputed_hashes(), identifier :: binary()) :: node_list()
  @callback list(params :: precomputed_hashes(), identifier :: integer()) :: node_list()
end
