defmodule CensysEx.TestHelpers do
  @moduledoc false

  @spec load_response(String.t(), integer()) :: CensysEx.result()
  def load_response(file_name, status_code \\ 200) do
    case File.read("./test/responses/" <> file_name <> ".json") do
      {:ok, body} ->
        Jason.decode!(body)
        |> CensysEx.Util.parse_body(status_code)

      err ->
        err
    end
  end
end
