defmodule RendevousHash.Murmur3 do
  @moduledoc """
  Pure Elixir implementation of MurmurHash3 (x86, 32-bit).

  This avoids NIF dependencies, making the library portable across
  glibc and musl-based systems (e.g., Alpine Linux in Firecracker guests).
  """

  import Bitwise

  @c1 0xCC9E2D51
  @c2 0x1B873593
  @mask32 0xFFFFFFFF

  @doc """
  Computes MurmurHash3 x86 32-bit hash of a binary with the given seed.
  """
  @spec hash(binary(), non_neg_integer()) :: non_neg_integer()
  def hash(data, seed \\ 0) when is_binary(data) and is_integer(seed) do
    len = byte_size(data)
    {h, tail} = body(data, band(seed, @mask32))
    h = tail_mix(h, tail)
    finalize(h, len)
  end

  defp body(<<k::little-unsigned-32, rest::binary>>, h) do
    k = band(k * @c1, @mask32)
    k = rotl32(k, 15)
    k = band(k * @c2, @mask32)

    h = bxor(h, k)
    h = rotl32(h, 13)
    h = band(h * 5 + 0xE6546B64, @mask32)

    body(rest, h)
  end

  defp body(tail, h), do: {h, tail}

  defp tail_mix(h, <<>>), do: h

  defp tail_mix(h, tail) do
    k =
      case tail do
        <<b1>> -> b1
        <<b1, b2>> -> bor(b2 <<< 8, b1)
        <<b1, b2, b3>> -> bor(bor(b3 <<< 16, b2 <<< 8), b1)
      end

    k = band(k * @c1, @mask32)
    k = rotl32(k, 15)
    k = band(k * @c2, @mask32)
    bxor(h, k)
  end

  defp finalize(h, len) do
    h = bxor(h, len)
    h = bxor(h, h >>> 16)
    h = band(h * 0x85EBCA6B, @mask32)
    h = bxor(h, h >>> 13)
    h = band(h * 0xC2B2AE35, @mask32)
    bxor(h, h >>> 16)
  end

  defp rotl32(x, r) do
    band(bor(x <<< r, x >>> (32 - r)), @mask32)
  end
end
