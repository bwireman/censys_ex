defmodule CensysEx.APIBehavior do
  @moduledoc false

  @type t :: module()

  @callback view(String.t(), String.t(), DateTime.t() | nil) :: {:error, any()} | {:ok, map()}
  @callback aggregate(String.t(), String.t(), String.t() | nil, integer()) ::
              {:error, any()} | {:ok, map()}
  @callback get(String.t(), String.t(), list(), keyword()) :: {:error, any()} | {:ok, map()}
end
