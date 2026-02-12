defmodule InsuranceWeb.PolicyLive.New do
  use InsuranceWeb, :live_view
  alias Insurance.Policies
  alias Insurance.Policies.Policy

  def mount(_, _, socket) do
    changeset = Policies.change_policy(%Policy{})
    {:ok, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"policy" => params}, socket) do
    case Policies.create_policy(params) do
      {:ok, _policy} ->
        {:noreply,
         socket
         |> put_flash(:info, "Policy created")
         |> push_navigate(to: "/policies")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
