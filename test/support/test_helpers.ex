defmodule CensysEx.TestHelpers do
  @moduledoc false
  use Dreamy

  @spec load_response(String.t(), integer()) :: CensysEx.result()
  def load_response(file_name, status_code \\ 200) do
    fallthrough File.read("./test/responses/" <> file_name <> ".json") do
      {:ok, body} ->
        Jason.decode!(body)
        |> CensysEx.Util.parse_body(status_code)
    end
  end
end
