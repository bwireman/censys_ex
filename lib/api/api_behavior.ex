defmodule CensysEx.APIBehavior do
  @moduledoc false

  @type t :: CensysEx.APIBehavior

  @callback view(String.t(), String.t(), DateTime.t() | nil) :: CensysEx.result()
  @callback aggregate(String.t(), String.t(), String.t() | nil, integer()) :: CensysEx.result()
  @callback get(String.t(), String.t(), list(), keyword()) :: CensysEx.result()

  # v1 get
  @callback get_v1(String.t(), String.t(), list(), keyword()) :: CensysEx.result()
end
