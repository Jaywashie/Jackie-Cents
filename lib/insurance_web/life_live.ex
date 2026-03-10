defmodule InsuranceWeb.LifeLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  @plans %{
    "akiba" => %{name: "Britam Akiba Life Savings Plan", base: 10000, icon: "💰"},
    "education" => %{name: "Britam Education Plan", base: 12000, icon: "🎓"},
    "whole_life" => %{name: "Britam Whole Life Plan", base: 15000, icon: "❤️"},
    "term_life" => %{name: "Britam Term Life Plan", base: 8000, icon: "📋"}
  }

  def mount(_, _, socket) do
    {:ok, assign(socket, selected_plan: nil, quote: nil, plans: @plans, saved: false)}
  end

  def handle_event("select_plan", %{"plan" => plan}, socket) do
    {:noreply, assign(socket, selected_plan: plan, quote: nil, saved: false)}
  end

  def handle_event("generate_quote", params, socket) do
    age = parse_int(params["age"])
    cover = parse_int(params["cover_amount"])
    base = socket.assigns.plans[socket.assigns.selected_plan].base
    total = base + age * 100 + div(cover, 1000)
    {:noreply, assign(socket, quote: total, saved: false)}
  end

  def handle_event("save_quote", _params, socket) do
    case socket.assigns.current_user do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Please log in to save a quote")
         |> push_navigate(to: "/users/log_in")}

      user ->
        plan = socket.assigns.plans[socket.assigns.selected_plan]

        quote_params = %{
          user_id: user.id,
          plan_name: plan.name,
          email: user.email,
          plan_type: "life",
          monthly_contribution: div(socket.assigns.quote, 12),
          estimated_value: socket.assigns.quote
        }

        case Quotes.create_quote(quote_params) do
          {:ok, quote} ->
            InsuranceWeb.Endpoint.broadcast("quotes", "new_quote", quote)
            {:noreply, assign(socket, saved: true) |> put_flash(:info, "Quote saved!")}

          {:error, _} ->
            {:noreply, put_flash(socket, :error, "Failed to save quote.")}
        end
    end
  end

  defp parse_int(nil), do: 0
  defp parse_int(""), do: 0
  defp parse_int(val), do: String.to_integer(val)
end
