defmodule Plugsnag do
  defmacro __using__(_env) do
    quote location: :keep do
      @before_compile Plugsnag
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do
      defoverridable [call: 2]

      def call(conn, opts) do
        try do
          super(conn, opts)
        rescue
          exception ->
            stacktrace = System.stacktrace

            exception
            |> Bugsnag.report(releaseStage: Atom.to_string(Mix.env), metaData: ([:host, :method, :path_info, :script_name, :request_path, :port, :scheme, :query_string]
            |> Enum.reduce(%{}, fn(x, acc) -> Map.put(acc, x, Map.get(conn, x)) end)
            |> Map.put(:req_headers, conn.req_headers |> Enum.into(%{}))))

            reraise exception, stacktrace
        end
      end
    end
  end
end
