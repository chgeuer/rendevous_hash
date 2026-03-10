defmodule RendevousHash.Native.GracefulInit do
  @moduledoc false

  # Replaces Rustler's rustler_init/0 with a version that swallows NIF load
  # failures. Registered as @before_compile AFTER Rustler's @before_compile,
  # so it runs second and can override via defoverridable.

  defmacro __before_compile__(_env) do
    quote do
      defoverridable rustler_init: 0

      @doc false
      def rustler_init do
        :code.purge(__MODULE__)

        {otp_app, path} = @load_from
        load_path = otp_app |> Application.app_dir(path) |> to_charlist()

        case :erlang.load_nif(load_path, @load_data) do
          :ok -> :ok
          {:error, _reason} -> :ok
        end
      end
    end
  end
end
