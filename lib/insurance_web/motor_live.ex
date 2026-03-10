defmodule InsuranceWeb.MotorLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  @impl true
  def mount(_params, _session, socket) do
    plans = [
      %{
        id: "comprehensive",
        name: "Motor Comprehensive",
        icon: "🚗",
        min_premium: 25000,
        description: "Full protection for your vehicle including accidents, theft and fire.",
        benefits: [
          "Accidental damage cover",
          "Theft protection",
          "Fire damage cover",
          "Windscreen cover",
          "Third party liability"
        ]
      },
      %{
        id: "third_party",
        name: "Third Party Only",
        icon: "🛡️",
        min_premium: 7500,
        description: "Affordable legal cover for damage caused to other people and property.",
        benefits: [
          "Third party injury cover",
          "Third party property damage",
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
     |> assign(:saved, false)
     |> assign(:vehicle_value, nil)
     |> assign(:quote_form, to_form(%{"vehicle_value" => "", "vehicle_age" => "", "usage" => ""}))}
  end

  @impl true
  def handle_event("select_plan", %{"id" => plan_id}, socket) do
    {:noreply, assign(socket, selected_plan: plan_id, quote: nil, saved: false)}
  end

  @impl true
  def handle_event("generate_quote", params, socket) do
    send(self(), {:calculate_quote, params})
    {:noreply, assign(socket, loading: true)}
  end

  @impl true
  def handle_info({:calculate_quote, params}, socket) do
    value = parse_int(params["vehicle_value"])
    age = parse_int(params["vehicle_age"])

    base_rate =
      case socket.assigns.selected_plan do
        "comprehensive" -> 0.05
        "third_party" -> 0.015
        _ -> 0.05
      end

    quote = round(value * base_rate + age * 200)

    {:noreply, socket |> assign(quote: quote, loading: false, vehicle_value: value, saved: false)}
  end

  @impl true
  def handle_event("save_quote", _params, socket) do
    case socket.assigns.current_user do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Please log in to save a quote")
         |> push_navigate(to: "/users/log_in")}

      user ->
        plan_name =
          case socket.assigns.selected_plan do
            "comprehensive" -> "Motor Comprehensive Insurance"
            "third_party" -> "Third Party Motor Insurance"
            _ -> "Motor Insurance"
          end

        quote_params = %{
          user_id: user.id,
          plan_name: plan_name,
          email: user.email,
          plan_type: "motor",
          monthly_contribution: div(socket.assigns.quote, 12),
          estimated_value: socket.assigns.quote
        }

        case Quotes.create_quote(quote_params) do
          {:ok, quote} ->
            InsuranceWeb.Endpoint.broadcast("quotes", "new_quote", %{
              id: quote.id,
              plan_name: quote.plan_name,
              plan_type: quote.plan_type,
              email: quote.email,
              monthly_contribution: quote.monthly_contribution,
              estimated_value: quote.estimated_value
            })

            {:noreply, assign(socket, saved: true) |> put_flash(:info, "Quote saved!")}

          {:error, _} ->
            {:noreply, put_flash(socket, :error, "Failed to save quote.")}
        end
    end
  end

  defp parse_int(nil), do: 0
  defp parse_int(""), do: 0
  defp parse_int(val) when is_binary(val), do: String.to_integer(val)
  defp parse_int(val), do: val
end
