defmodule CensysEx.Util do
  @moduledoc false

  # RFC3339 format
  @at_time_format "%Y-%m-%dT%H:%M:%S"

  @invalid_message "Invalid API response"
  @invalid_api_resp {:error, @invalid_message}

  @spec parse_body(map(), integer()) :: CensysEx.result()
  def parse_body(body, status_code) do
    parse_status_code(body, status_code)
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

  @spec build_diff_params(String.t() | nil, DateTime.t() | nil, DateTime.t() | nil) ::
          keyword() | []
  def build_diff_params(ip_b, at_time, at_time_b),
    do:
      if(ip_b, do: [ip_b: ip_b], else: Keyword.new()) ++
        if(at_time, do: [at_time: format_datetime!(at_time)], else: Keyword.new()) ++
        if(at_time_b, do: [at_time_b: format_datetime!(at_time_b)], else: Keyword.new())

  @spec build_experimental_get_host_events(integer(), boolean(), DateTime.t() | nil, DateTime.t() | nil) ::
          keyword() | []
  def build_experimental_get_host_events(per_page, reversed, start_time, end_time),
    do:
      [per_page: per_page, reversed: reversed] ++
        if(start_time, do: [start_time: format_datetime!(start_time)], else: Keyword.new()) ++
        if(end_time, do: [end_time: format_datetime!(end_time)], else: Keyword.new())

  @spec format_datetime!(DateTime.t()) :: String.t()
  defp format_datetime!(at_time), do: Timex.format!(at_time, @at_time_format, :strftime)

  @spec parse_status_code(map(), integer()) :: CensysEx.result()
  defp parse_status_code(decoded, status_code) do
    status_code = Map.get(decoded, "code", status_code)

    case status_code do
      code when is_integer(code) and code >= 400 ->
        {:error,
         Map.get(decoded, "error", "Unknown Error occurred with status code: " <> Integer.to_string(status_code))}

      code when is_integer(code) and code >= 200 and code < 300 ->
        {:ok, decoded}

      _ ->
        @invalid_api_resp
    end
  end
end
