defmodule CensysEx do
  @moduledoc """
  Root of the CensysEx lib
  """

  @typedoc """
  Return type of CensysEx API wrappers that aren't streams
  """
  @type result :: Dreamy.Types.result(map(), any())

  @typedoc """
  Return type of streaming wrappers
  """
  # type parameter for documentation purposes only
  @type result_stream(t) :: Dreamy.Types.enumerable(t)
end
