defmodule CensysEx.Util do
  @moduledoc false

  def get_client, do: Application.get_env(:censys_ex, :client, CensysEx.API)

  @spec parse_body(String.t()) :: {:error, any} | {:ok, map}
  def parse_body(body) do
    case Jason.decode(body) do
      {:ok, decoded} ->
        case Map.get(decoded, "code") do
          code when code >= 400 -> {:error, Map.get(decoded, "error", "Unknown Error occurred")}
          code when code >= 200 and code < 300 -> {:ok, decoded}
          nil -> {:error, "Invalid API response"}
        end

      err ->
        err
    end
  end

  @spec build_view_params(DateTime.t()) :: [{:at_time, String.t()}] | []
  def build_view_params(at_time) do
    case at_time do
      nil -> []
      _ -> [at_time: Timex.format!(at_time, "%Y-%m-%dT%H:%M:%S", :strftime)]
    end
  end

  @spec build_aggregate_params(String.t(), String.t(), integer()) :: keyword()
  def build_aggregate_params(field, query, num_buckets) do
    params = [field: field, num_buckets: num_buckets]
    if(query != nil, do: [{:q, query} | params], else: params)
  end
end
