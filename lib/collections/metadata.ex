defmodule CensysEx.Metadata do
  @moduledoc """
  Functions related to the /metadata endpoints on search.censys.io
  """

  @doc """
  hits metadata/hosts returning the possible values for the services.service_name field in search queries.

  - API docs: https://search.censys.io/api#/hosts/getHostMetadata
  """
  @spec hosts_metadata :: CensysEx.result()
  def hosts_metadata, do: CensysEx.API.get("metadata", "hosts", [], [])
end
