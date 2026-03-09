defmodule InsuranceWeb.LifeLive do
  use InsuranceWeb, :live_view

  @plans %{
    "akiba" => %{
      name: "Britam Akiba Life Savings Plan",
      base: 10000
    },
    "education" => %{
      name: "Britam Education Plan",
      base: 12000
    },
    "whole_life" => %{
      name: "Britam Whole Life Plan",
      base: 15000
    },
    "term_life" => %{
      name: "Britam Term Life Plan",
      base: 8000
    }
  }

  def mount(_, _, socket) do
    {:ok,
     assign(socket,
       selected_plan: nil,
       quote: nil,
       plans: @plans
     )}
  end

  def handle_event("select_plan", %{"plan" => plan}, socket) do
    {:noreply, assign(socket, selected_plan: plan, quote: nil)}
  end

  def handle_event("generate_quote", params, socket) do
    age = parse_int(params["age"])
    cover = parse_int(params["cover_amount"])

    base = socket.assigns.plans[socket.assigns.selected_plan].base

    # Simple pricing logic (example)
    total = base + (age * 100) + div(cover, 1000)

    {:noreply, assign(socket, :quote, total)}
  end

  defp parse_int(nil), do: 0
  defp parse_int(""), do: 0
  defp parse_int(val), do: String.to_integer(val)
end
