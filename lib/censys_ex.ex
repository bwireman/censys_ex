defmodule CensysEx do
  @moduledoc """
  Root of the CensysEx lib
  """

  @typedoc """
  Return type of CensysEx API wrappers that aren't streams
  """
  @type result :: {:ok, map()} | {:error, any}

  @typedoc """
  Return type of streaming wrappers
  """
  # type parameter for documentation purposes only
  @type result_stream(_t) :: Enumerable.t()
end
