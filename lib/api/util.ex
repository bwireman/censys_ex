defmodule CensysEx.Util do
  @moduledoc false

  def get_client do
    Application.get_env(:censys_ex, :client, CensysEx.API)
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

  def build_view_params(at_time) do
    case at_time do
      nil -> []
      _ -> [at_time: Timex.format!(at_time, "%Y-%m-%dT%H:%M:%S", :strftime)]
    end
  end

  def build_aggregate_params(field, query, num_buckets) do
    params = [field: field, num_buckets: num_buckets]
    if(query != nil, do: [{:q, query} | params], else: params)
  end
end
