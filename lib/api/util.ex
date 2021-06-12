defmodule CensysEx.Util do
  @moduledoc false

  def get_client do
    Application.get_env(:censys_elixir, :client, CensysEx.API)
  end

  def parse_body(body) do
    case Poison.decode(body) do
      {:ok, decoded} ->
        case Map.get(decoded, "code") do
          code when code >= 400 -> {:error, Map.get(decoded, "error", "Unknown Error occurred")}
          nil -> {:error, "Invalid API response"}
          code when code >= 200 and code < 300 -> {:ok, decoded}
        end

      err ->
        err
    end
  end
end
