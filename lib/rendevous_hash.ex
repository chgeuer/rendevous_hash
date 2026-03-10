defmodule RendevousHash do
  @moduledoc """
  Main interface for rendezvous hashing operations.

  Delegates to either the native Rust implementation for performance
  or the pure Elixir implementation for compatibility.

  ## Properties & Guarantees

  This implementation satisfies the following properties (verified via property-based tests):

  - **Determinism** — same inputs always produce the same node ranking.
  - **Permutation invariance** — the order in which nodes are supplied does not affect the output.
  - **Complete coverage** — the output is a permutation of the input nodes (no nodes lost or duplicated).
  - **Consistent prefix** — requesting the top-*k* nodes returns a prefix of the full ranking.
    Increasing the replica count never changes which nodes were already selected.
  - **Minimal disruption** — removing a node only reassigns keys that were mapped to it.
    All other keys remain on the same node.
  - **Relative order preservation** — removing a node preserves the relative order of all remaining nodes.
  - **Cross-implementation consistency** — the Elixir and Rust implementations produce identical results.
  """
  @behaviour RendevousHash.Behaviour

  @impl RendevousHash.Behaviour
  def hash(x), do: RendevousHash.Native.hash(x)

  @doc """
  Returns the top `num_items` nodes for the given `identifier`.

  The result is always a prefix of the full ranking returned by `list/2`,
  so increasing `num_items` never changes the nodes already selected.
  """
  def list(params, identifier, num_items), do: list(params, identifier) |> Enum.take(num_items)

  @impl RendevousHash.Behaviour
  def list(params, identifier), do: RendevousHash.Native.list(params, identifier)

  @impl RendevousHash.Behaviour
  def pre_compute_list(list), do: RendevousHash.Native.pre_compute_list(list)
end
