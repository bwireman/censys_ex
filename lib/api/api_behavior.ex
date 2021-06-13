defmodule CensysEx.APIBehavior do
  @moduledoc false

  @callback view(String.t(), String.t(), DateTime.t()) :: {:error, any()} | {:ok, map()}
  @callback aggregate(String.t(), String.t(), String.t(), integer()) ::
              {:error, any()} | {:ok, map()}
  @callback get(String.t(), String.t(), list(), keyword()) :: {:error, any()} | {:ok, map()}
end
