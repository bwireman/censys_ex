defmodule CensysEx.Util do
  @moduledoc false

  @at_time_format "%Y-%m-%dT%H:%M:%S"

  @spec get_client() :: CensysEx.APIBehavior.t()
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

  @spec build_view_params(DateTime.t() | nil) :: [{:at_time, String.t()}] | []
  def build_view_params(at_time) do
    case at_time do
      nil -> []
      _ -> [at_time: Timex.format!(at_time, @at_time_format, :strftime)]
    end
  end

  @spec build_aggregate_params(String.t(), String.t() | nil, integer()) :: keyword()
  def build_aggregate_params(field, query, num_buckets) do
    params = [field: field, num_buckets: num_buckets]
    if(query != nil, do: [{:q, query} | params], else: params)
  end

  @spec build_diff_params(String.t() | nil, DateTime.t() | nil, DateTime.t() | nil) :: keyword() | []
  def build_diff_params(ip_b, at_time, at_time_b) do
    params = if(ip_b, do: [ip_b: ip_b], else: Keyword.new())
    params = if(at_time, do: [{:at_time, format_datetime!(at_time)} | params], else: params)

    if(at_time_b, do: [{:at_time_b, format_datetime!(at_time_b)} | params], else: params)
  end

  defp format_datetime!(at_time), do: Timex.format!(at_time, @at_time_format, :strftime)
end
