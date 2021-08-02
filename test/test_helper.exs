defmodule CensysEx.TestHelpers do
  @spec load_response(String.t()) :: CensysEx.result()
  def load_response(file_name) do
    case File.read("./test/responses/" <> file_name <> ".json") do
      {:ok, body} ->
        CensysEx.Util.parse_body(body)

      err ->
        err
    end
  end
end

Mox.defmock(CensysEx.ApiMock, for: CensysEx.APIBehavior)
Application.put_env(:censys_ex, :client, CensysEx.ApiMock)
ExUnit.start()
