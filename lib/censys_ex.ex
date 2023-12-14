defmodule CensysEx do
  @moduledoc """
  Root of the CensysEx lib
  """
  use Dreamy

  @typedoc """
  Return type of CensysEx API wrappers that aren't streams
  """
  @type result :: Types.result(map(), any())

  @typedoc """
  Return type of streaming wrappers
  """
  # type parameter for documentation purposes only
  @type result_stream(t) :: Types.enumerable(t)
end
