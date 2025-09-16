defmodule RendevousHash.Helpers.AllPermutations do
  @moduledoc """
  Utility for generating combinations and permutations of sets.

  Provides functions to create various permutations from a given set,
  useful for testing different node arrangements and configurations.
  """
  # A little module to create a bunch of permutations
  def generate_all(set) do
    list = MapSet.to_list(set)

    Range.new(2, Enum.count(set))
    |> Enum.flat_map(fn subset_size ->
      list
      |> combinations(subset_size)
      |> Enum.flat_map(&permutations/1)
    end)
  end

  # Generate all combinations of size k from a list
  defp combinations(_, 0), do: [[]]
  defp combinations([], _), do: []

  defp combinations([h | t], k) do
    for(tail <- combinations(t, k - 1), do: [h | tail]) ++ combinations(t, k)
  end

  # Generate all permutations of a list
  defp permutations([]), do: [[]]

  defp permutations(list) do
    for elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest]
  end
end
