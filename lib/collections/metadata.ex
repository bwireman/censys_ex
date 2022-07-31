defmodule CensysEx.Metadata do
  @moduledoc """
  Functions related to the /metadata endpoints on search.censys.io
  """

  @doc """
  hits metadata/hosts returning the possible values for the services.service_name field in search queries.

  - API docs: https://search.censys.io/api#/hosts/getHostMetadata
  """

  alias CensysEx.API

  @spec hosts_metadata(API.t()) :: CensysEx.result()
  def hosts_metadata(client), do: API.get(client, "metadata", "hosts", [])
end
