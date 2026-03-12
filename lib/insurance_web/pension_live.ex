defmodule InsuranceWeb.PensionLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  # Britam guaranteed minimum rate: 5% p.a. compounded (per official policy documents)
  # Tax deductible contributions: max KES 20,000/month or 1/3 of monthly income, whichever is lower
  # Admin fee: 1.5% of contributions p.a. (waived first year)

  @guaranteed_rate 0.05
  @admin_fee_rate  0.015

  @impl true
  def mount(_params, _session, socket) do
    plans = [
      %{
        id: "personal_pension",
        name: "Personal Pension Plan",
        provider: "Britam Life Assurance Co. (K) Ltd",
        min_contribution: 2_000,
        tax_deductible_max: 20_000,
        retirement_age: "50 – 65 years",
        rate: @guaranteed_rate,
        payout_type: "pension",
        description:
          "A flexible defined-contribution personal retirement savings plan registered with the " <>
          "Retirement Benefits Authority (RBA) and approved under the Income Tax Act (Cap. 470). " <>
          "Designed for employed individuals and self-employed professionals. Contributions are tax " <>
          "deductible at source up to KES 20,000/month. A member can assign up to 60% of the " <>
          "accumulated fund as a pension-backed mortgage.",
        benefits: [
          "Tax deductible contributions (max KES 20,000/month or 1/3 of income)",
          "Guaranteed minimum return of 5% p.a. compounded",
          "Portable — not affected by change of employment",
          "Flexible contribution frequency (monthly, quarterly, semi-annual, annual)",
          "Pension-backed mortgage: up to 60% of accumulated fund",
          "Choice of Pension Fund (1/3 lump sum + 2/3 annuity) or Provident Fund (full lump sum)",
          "Death benefit: total accumulated fund paid to named beneficiaries"
        ]
      },
      %{
        id: "individual_retirement",
        name: "Individual Retirement Plan",
        provider: "Britam Life Assurance Co. (K) Ltd",
        min_contribution: 500,
        tax_deductible_max: 20_000,
        retirement_age: "50 – 65 years",
        rate: @guaranteed_rate,
        payout_type: "provident",
        description:
          "A structured individual retirement savings scheme open to all Kenyan residents including " <>
          "the self-employed, allowing contributions from as low as KES 500/month with no upper limit. " <>
          "Registered with the RBA and KRA. Members receive annual personalized statements. " <>
          "The plan offers a choice between a Provident Fund (full lump sum payout) or a Pension Fund " <>
          "(1/3 lump sum + 2/3 regular annuity income for life).",
        benefits: [
          "Low minimum contribution from KES 500/month",
          "Guaranteed capital — accumulated benefits protected against reduction",
          "Interest rate guaranteed not to fall below 5% p.a.",
          "Annual personalized statement of savings and interest",
          "Tax-exempt investment income",
          "Option to withdraw accumulated funds subject to RBA regulations",
          "Death benefit: total accumulated fund paid to named beneficiaries"
        ]
      }
    ]

    {:ok,
     socket
     |> assign(:plans, plans)
     |> assign(:selected_plan, nil)
     |> assign(:quote, nil)
     |> assign(:monthly_contribution, nil)
     |> assign(:years_to_retire, nil)
     |> assign(:saved, false)}
  end

  @impl true
  def handle_event("select_plan", %{"id" => id}, socket) do
    plan = Enum.find(socket.assigns.plans, &(&1.id == id))
    {:noreply, assign(socket, selected_plan: plan, quote: nil, saved: false)}
  end

  @impl true
  def handle_event("generate_quote", params, socket) do
    age     = parse_int(params["age"])
    monthly = parse_int(params["monthly_contribution"])
    retire  = parse_int(params["retirement_age"])

    years   = max(retire - age, 0)
    annual  = monthly * 12

    # Future value of regular contributions compounded annually at guaranteed 5% p.a.
    # FV = PMT × [((1 + r)^n - 1) / r]  where PMT = annual contribution, r = rate, n = years
    rate     = @guaranteed_rate
    fv_factor =
      if years > 0 and rate > 0 do
        (:math.pow(1 + rate, years) - 1) / rate
      else
        years * 1.0
      end

    gross_fv = round(annual * fv_factor)

    # Deduct admin fee: 1.5% of total contributions (waived year 1, so on n-1 years)
    total_contributions = annual * years
    admin_deduction     = round(total_contributions * @admin_fee_rate * max(years - 1, 0) / years)
    estimated           = max(gross_fv - admin_deduction, 0)

    {:noreply,
     socket
     |> assign(:quote, estimated)
     |> assign(:monthly_contribution, monthly)
     |> assign(:years_to_retire, years)
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
        plan      = socket.assigns.selected_plan
        quote_val = socket.assigns.quote || 0
        monthly   = socket.assigns.monthly_contribution || 0

        quote_params = %{
          user_id:              user.id,
          plan_name:            plan.name,
          email:                user.email,
          plan_type:            "pension",
          monthly_contribution: monthly,
          estimated_value:      quote_val
        }

        case Quotes.create_quote(quote_params) do
          {:ok, saved_quote} ->
            InsuranceWeb.Endpoint.broadcast("quotes", "new_quote", %{
              id:                   saved_quote.id,
              plan_name:            saved_quote.plan_name,
              plan_type:            saved_quote.plan_type,
              email:                saved_quote.email,
              monthly_contribution: saved_quote.monthly_contribution,
              estimated_value:      saved_quote.estimated_value
            })
            {:noreply, socket |> assign(saved: true) |> put_flash(:info, "Quote saved successfully!")}

          {:error, _reason} ->
            {:noreply, put_flash(socket, :error, "Failed to save quote. Please try again.")}
        end
    end
  end

  def format_number(n) when is_integer(n) do
    n
    |> Integer.to_string()
    |> String.reverse()
    |> String.graphemes()
    |> Enum.chunk_every(3)
    |> Enum.join(",")
    |> String.reverse()
  end
  def format_number(_), do: "0"

  defp parse_int(nil), do: 0
  defp parse_int(""), do: 0
  defp parse_int(val) do
    case Integer.parse(to_string(val)) do
      {n, _} -> n
      :error  -> 0
    end
  end
end
