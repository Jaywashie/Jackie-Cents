defmodule InsuranceWeb.PensionLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  @impl true
  def mount(_params, session, socket) do

    plans = [
      %{
        id: "personal_pension",
        name: "Personal Pension Plan",
        provider: "Britam",
        min_contribution: 2000,
        range: "KES 2,000 – No Maximum",
        retirement_age: "50 – 65 years",
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

    {:ok, socket

     |> assign(:plans, plans)
     |> assign(:selected_plan, nil)
     |> assign(:quote, nil)
     |> assign(:monthly_contribution, nil)
     |> assign(:loading, false)
     |> assign(:saving, false)}

  end
  # ================= SELECT PLAN =================

  @impl true
  def handle_event("select_plan", %{"id" => id}, socket) do
    plan =
      Enum.find(socket.assigns.plans, fn p ->
        p.id == id
      end)

    {:noreply, assign(socket, :selected_plan, plan)}
  end

  # ================= GENERATE QUOTE =================

  @impl true
  def handle_event("generate_quote", params, socket) do
    age = String.to_integer(params["age"])
    monthly = String.to_integer(params["monthly_contribution"])

    multiplier =
      case socket.assigns.selected_plan.id do
        "personal_pension" -> 1.10
        "individual_pension" -> 1.25
      end

    estimated =
      round(monthly * 12 * (65 - age) * multiplier)

    {:noreply,
     socket
     |> assign(:quote, estimated)
     |> assign(:monthly_contribution, monthly)}
  end

  # ================= SAVE QUOTE =================

  @impl true
  def handle_event("save_quote", _params, socket) do
plan = socket.assigns.selected_plan

if plan == nil do
{:noreply, socket |> put_flash(:error, "Please select a plan first")}
  else

    case socket.assigns.current_user do
      nil ->
         {:noreply, socket |> put_flash(:error, "Please login to save a quote")}

    user ->
    quote_params = %{
      user_id: user.id,
      plan_name: plan.name,
      plan_type: "pension",
      monthly_contribution: socket.assigns.monthly_contribution,
      estimated_value: socket.assigns.quote
    }

    case Quotes.create_quote(quote_params) do
      {:ok, quote} ->

     # Broadcast new quote
    InsuranceWeb.Endpoint.broadcast("quotes", "new_quote", quote)

        {:noreply,
         socket
         |> assign(:saving, false)
         |> put_flash(:info, "Quote saved successfully")
        }

      {:error, _} ->
        {:noreply, socket |>  put_flash(:error, "Failed to save quote")}
    end
  end
  end
end
end
