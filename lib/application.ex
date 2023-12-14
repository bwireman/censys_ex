defmodule CensysEx.Application do
  @moduledoc false
  use Application
  use Dreamy

  @spec start(any, any) :: Types.result(pid(), any())
  def start(_type, _args) do
    children = [
      {Finch, name: CensysExFinch}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
