defmodule InsuranceWeb.LifeLive do
  use InsuranceWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  # UI
def render(assigns) do
    ~H"""

    """
  end

  # button events
  def handle_event("go_life", _, socket) do
  {:noreply, push_navigate(socket, to: "/life")}
end


end
