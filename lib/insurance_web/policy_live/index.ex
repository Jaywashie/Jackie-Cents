defmodule InsuranceWeb.PolicyLive.Index do
  use InsuranceWeb, :live_view
  alias Insurance.Policies

  def mount(_, _, socket) do
    {:ok, assign(socket, policies: Policies.list_policies())}
  end
end
