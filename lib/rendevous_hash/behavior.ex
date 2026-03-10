defmodule RendevousHash.Behaviour do
  @moduledoc """
  A behaviour for implementing Rendevous Hashing in Elixir.

  Any implementation of this behaviour is expected to satisfy the following properties:

  - **Determinism** — `list/2` returns the same ranking for the same inputs on every call.
  - **Permutation invariance** — the order of nodes passed to `pre_compute_list/1` does not affect
    the ranking produced by `list/2`.
  - **Complete coverage** — `list/2` returns a permutation of the input nodes (no nodes lost or duplicated).
  - **Minimal disruption** — removing a node only reassigns keys that were previously mapped to it.
  - **Relative order preservation** — removing a node preserves the relative order of all remaining nodes.
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
