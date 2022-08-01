defmodule CensysEx.ClientCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  setup do
    %{client: CensysEx.API.client()}
  end
end
