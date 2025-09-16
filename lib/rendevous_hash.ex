defmodule RendevousHash do
  @moduledoc """
  Main interface for rendezvous hashing operations.

  Delegates to either the native Rust implementation for performance
  or the pure Elixir implementation for compatibility.
  """
  @behaviour RendevousHash.Behaviour

  @impl RendevousHash.Behaviour
  def hash(x), do: RendevousHash.Native.hash(x)

  def list(params, identifier, num_items), do: list(params, identifier) |> Enum.take(num_items)

  @impl RendevousHash.Behaviour
  def list(params, identifier), do: RendevousHash.Native.list(params, identifier)

  @impl RendevousHash.Behaviour
  def pre_compute_list(list), do: RendevousHash.Native.pre_compute_list(list)
end
