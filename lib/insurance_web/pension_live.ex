defmodule InsuranceWeb.PensionLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  @impl true
  def mount(_params, _session, socket) do
    plans = [
      %{
        id: "personal_pension",
        name: "Personal Pension Plan",
        provider: "Britam",
        min_contribution: 2000,
        range: "KES 2,000 – No Maximum",
        retirement_age: "50 – 65 years",
        multiplier: 1.10,
        description:
          "A flexible personal retirement savings plan designed for individuals and self-employed professionals.",
        benefits: [
          "Tax deductible contributions",
          "Flexible payment options (monthly, quarterly, yearly)",
          "Compound investment growth",
          "Portable even when changing jobs",
          "Pension-backed mortgage option"
        ]
      },
      %{
        id: "individual_pension",
        name: "Individual Retirement Plan",
        provider: "Britam",
        min_contribution: 500,
        range: "KES 500 – No Maximum",
        retirement_age: "50 – 65 years",
        multiplier: 1.25,
        description:
          "A structured retirement savings scheme allowing individuals to build a guaranteed retirement income.",
        benefits: [
          "Professional fund management",
          "Guaranteed minimum return",
          "Option for lump sum or pension annuity",
          "Capital protection",
          "Death benefits for beneficiaries"
        ]
      }
    ]

    {:ok,
     socket
     |> assign(:plans, plans)
     |> assign(:selected_plan, nil)
     |> assign(:quote, nil)
     |> assign(:monthly_contribution, nil)
     |> assign(:saved, false)}
  end

  @impl true
  def handle_event("select_plan", %{"id" => id}, socket) do
    plan = Enum.find(socket.assigns.plans, &(&1.id == id))
    {:noreply, assign(socket, selected_plan: plan, quote: nil, saved: false)}
  end

  @impl true
  def handle_event("generate_quote", params, socket) do
    age = String.to_integer(params["age"])
    monthly = String.to_integer(params["monthly_contribution"])
    multiplier = socket.assigns.selected_plan.multiplier
    estimated = round(monthly * 12 * (65 - age) * multiplier)

    {:noreply,
     socket
     |> assign(:quote, estimated)
     |> assign(:monthly_contribution, monthly)
     |> assign(:saved, false)}
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
        plan = socket.assigns.selected_plan

        quote_params = %{
          user_id: user.id,
          plan_name: plan.name,
          email: user.email,
          plan_type: "pension",
          monthly_contribution: socket.assigns.monthly_contribution,
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

            {:noreply, assign(socket, saved: true) |> put_flash(:info, "Quote saved successfully!")}

          {:error, _} ->
            {:noreply, put_flash(socket, :error, "Failed to save quote.")}
        end
    end
  end
end
