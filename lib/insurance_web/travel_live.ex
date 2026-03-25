defmodule InsuranceWeb.TravelLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  # Travel Insurance Plans
  # Premiums based on destination zone, trip duration, and number of travellers
  # Zone A: East Africa / Africa
  # Zone B: Europe / North America / Asia / Rest of World

  @plans %{
    "individual_basic" => %{
      name: "Individual Travel Basic",
      icon: "",
      description:
        "Essential travel protection for single trips within Africa and East Africa. " <>
        "Covers emergency medical expenses, trip cancellation, and lost baggage. " <>
        "Ideal for frequent regional travellers.",
      zone_a_daily: 150,
      zone_b_daily: 250,
        min_age: 1,
      max_age: 70,
      benefits: [
        "Emergency medical & hospitalisation: up to KES 1,500,000",
        "Medical evacuation & repatriation",
        "Trip cancellation & curtailment: up to KES 150,000",
        "Lost / delayed baggage: up to KES 80,000",
        "Personal accident: up to KES 500,000",
        "24/7 worldwide emergency assistance"
      ]
    },
    "individual_comprehensive" => %{
      name: "Individual Travel Comprehensive",
      icon: "",
      description:
        "Full-cover travel insurance for individuals travelling regionally or internationally. " <>
        "Includes higher medical limits, business equipment cover, and legal assistance. " <>
        "Covers pre-existing conditions after disclosure.",
      zone_a_daily: 280,
      zone_b_daily: 480,
      min_age: 1,
      max_age: 75,
      benefits: [
        "Emergency medical & hospitalisation: up to KES 7,500,000",
        "Medical evacuation & repatriation (unlimited)",
        "Trip cancellation & curtailment: up to KES 500,000",
        "Lost / delayed baggage: up to KES 200,000",
        "Personal accident: up to KES 2,000,000",
        "Business equipment & money: up to KES 150,000",
        "Legal & bail bond assistance: up to KES 300,000",
        "24/7 worldwide emergency assistance"
      ]
    },
    "family" => %{
      name: "Family Travel Plan",
      icon: "",
      description:
        "Comprehensive travel cover for families travelling together. " <>
        "One flat premium covers two adults plus up to four children under 18. " <>
        "Includes school-age children's extra cover and family emergency reunion benefit.",
      zone_a_daily: 420,
      zone_b_daily: 720,
      min_age: 1,
      max_age: 70,
      benefits: [
        "Covers 2 adults + up to 4 children (under 18)",
        "Emergency medical per person: up to KES 5,000,000",
        "Medical evacuation (full family)",
        "Trip cancellation: up to KES 400,000",
        "Lost / delayed baggage per person: up to KES 150,000",
        "Family reunion benefit: up to KES 200,000",
        "Children's activity cancellation cover",
        "24/7 worldwide emergency assistance"
      ]
    },
    "annual_multi_trip" => %{
      name: "Annual Multi-Trip Plan",
      icon: "",
      description:
        "Cost-effective annual cover for frequent travellers. A single annual premium covers " <>
        "unlimited trips (up to 90 days per trip) worldwide. Automatically renews. " <>
        "Ideal for business travellers and executives.",
      zone_a_annual: 18_000,
      zone_b_annual: 35_000,
      min_age: 18,
      max_age: 65,
      benefits: [
        "Unlimited trips per year (max 90 days per trip)",
        "Emergency medical per trip: up to KES 7,500,000",
        "Medical evacuation & repatriation",
        "Trip cancellation per trip: up to KES 400,000",
        "Baggage per trip: up to KES 180,000",
        "Business trip interruption cover",
        "Personal accident: up to KES 2,000,000",
        "24/7 worldwide emergency assistance"
      ]
    }
  }

  @zones [
    {"zone_a", "Zone A — East Africa / Africa"},
    {"zone_b", "Zone B — Europe / Asia / Americas / Rest of World"}
  ]

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       selected_plan: nil,
       quote: nil,
       quote_data: nil,
       saved: false
     )}
  end

  def handle_event("select_plan", %{"plan" => plan}, socket) do
    {:noreply, assign(socket, selected_plan: plan, quote: nil, quote_data: nil, saved: false)}
  end

  def handle_event("generate_quote", params, socket) do
    plan_key = socket.assigns.selected_plan
    plan     = @plans[plan_key]

    zone       = params["zone"] || "zone_a"
    days       = parse_int(params["days"])
    travellers = parse_int(params["travellers"])

    annual_plan? = plan_key == "annual_multi_trip"

    annual_premium =
      if annual_plan? do
        base = if zone == "zone_a", do: plan.zone_a_annual, else: plan.zone_b_annual
        base * max(travellers, 1)
      else
        daily_rate = if zone == "zone_a", do: plan.zone_a_daily, else: plan.zone_b_daily
        daily_rate * max(days, 1) * max(travellers, 1)
      end

    # IRA levy: 0.25% + stamp duty KES 40
    levy  = round(annual_premium * 0.0025)
    total = annual_premium + levy + 40

    quote_data = %{
      plan:         plan.name,
      zone:         zone,
      days:         days,
      travellers:   travellers,
      annual_plan?: annual_plan?,
      base_premium: annual_premium,
      levy:         levy,
      total:        total,
      monthly:      div(total, 12)
    }

    {:noreply, assign(socket, quote: total, quote_data: quote_data, saved: false)}
  end

  def handle_event("save_quote", _params, socket) do
    case socket.assigns.current_user do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Please log in to save a quote")
         |> push_navigate(to: "/users/log_in")}

      user ->
        qd        = socket.assigns.quote_data
        quote_val = socket.assigns.quote || 0

        quote_params = %{
          user_id:              user.id,
          plan_name:            "Travel Insurance – #{qd.plan}",
          email:                user.email,
          plan_type:            "travel",
          monthly_contribution: qd.monthly,
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

          {:error, _} ->
            {:noreply, put_flash(socket, :error, "Failed to save quote. Please try again.")}
        end
    end
  end

  def plans,  do: @plans
  def zones,  do: @zones

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

  defp parse_int(nil), do: 1
  defp parse_int(""), do: 1
  defp parse_int(val) do
    case Integer.parse(to_string(val)) do
      {n, _} -> max(n, 1)
      :error  -> 1
    end
  end
end
