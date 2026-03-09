defmodule InsuranceWeb.MotorLive do
  use InsuranceWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    plans = [
      %{
        id: "comprehensive",
        name: "Motor Comprehensive Insurance",
        provider: "Insurance",
        min_premium: 25000,
        description: "Full protection for your vehicle including accidents, theft and fire.",
        benefits: [
          "Covers accidental damage",
          "Theft protection",
          "Fire damage cover",
          "Windscreen cover",
          "Third party liability"
        ]
      },
      %{
        id: "third_party",
        name: " Third Party Insurance",
        provider: "Insurance",
        min_premium: 7500,
        description: "Affordable legal cover for damage caused to other people and property.",
        benefits: [
          "Covers third party injuries",
          "Covers third party property damage",
          "Legal liability protection",
          "Lowest cost motor cover"
        ]
      }
    ]

    {:ok,
     socket
     |> assign(:plans, plans)
     |> assign(:selected_plan, nil)
     |> assign(:quote, nil)
     |> assign(:loading, false)
     |> assign(:saving, false)
     |> assign(:quote_form, to_form(%{
        "vehicle_value" => "",
        "vehicle_age" => "",
        "usage" => ""
      }))}
  end

  # ================= PLAN SELECT =================

  def handle_event("select_plan", %{"id" => plan_id}, socket) do
    {:noreply, assign(socket, :selected_plan, plan_id)}
  end

  # ================= GENERATE QUOTE =================

  def handle_event("generate_quote", params, socket) do
    send(self(), {:calculate_quote, params})
    {:noreply, assign(socket, :loading, true)}
  end

  def handle_info({:calculate_quote, params}, socket) do
    value = String.to_integer(params["vehicle_value"])
    age = String.to_integer(params["vehicle_age"])

    base_rate =
      case socket.assigns.selected_plan do
        "comprehensive" -> 0.05
        "third_party" -> 0.015
      end

    quote =
      round(value * base_rate + age * 200)

    {:noreply,
     socket
     |> assign(:quote, quote)
     |> assign(:loading, false)}
  end

  # ================= SAVE QUOTE =================

  def handle_event("save_quote", _params, socket) do
    # Replace with DB call
    IO.inspect(socket.assigns.quote, label: "Saved Quote")

    {:noreply, assign(socket, :saving, true)}
  end
end
