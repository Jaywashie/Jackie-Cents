defmodule InsuranceWeb.AmaniShieldLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  # Amani Shield — Personal Accident + Property Cover
  # A bundled personal protection plan covering:
  # 1. Personal Accident (PA) — death, disability, medical expenses
  # 2. Home Contents — theft, fire, malicious damage
  # 3. Personal Liability — third-party bodily injury / property damage
  # 4. Critical Illness top-up (optional)

  @plans %{
    "amani_basic" => %{
      name: "Amani Shield Basic",
      icon: "",
      annual_premium: 8_500,
      description:
        "A simple, all-in-one personal protection plan covering accidental death, " <>
        "permanent disability, emergency medical expenses from accidents, and home " <>
        "contents against theft and fire. Ideal for individuals and young families " <>
        "looking for affordable bundled cover.",
      pa_death:        500_000,
      pa_disability:   500_000,
      pa_medical:       50_000,
      home_contents:   200_000,
      personal_liab:   500_000,
      critical_illness: nil,
      benefits: [
        "Accidental death: KES 500,000",
        "Permanent total disability: KES 500,000",
        "Emergency medical (accident): KES 50,000",
        "Home contents (theft, fire): KES 200,000",
        "Personal liability to third parties: KES 500,000",
        "24/7 emergency assistance hotline",
        "No medical underwriting required"
      ]
    },
    "amani_plus" => %{
      name: "Amani Shield Plus",
      icon: "",
      annual_premium: 18_500,
      description:
        "Enhanced bundled cover with higher personal accident limits, broader home " <>
        "contents protection, and an optional critical illness benefit. Includes " <>
        "income replacement for temporary disability and a hospital cash benefit. " <>
        "Designed for working professionals and homeowners.",
      pa_death:          2_000_000,
      pa_disability:     2_000_000,
      pa_medical:          150_000,
      home_contents:       500_000,
      personal_liab:     1_000_000,
      critical_illness:    500_000,
      benefits: [
        "Accidental death: KES 2,000,000",
        "Permanent total disability: KES 2,000,000",
        "Emergency medical (accident): KES 150,000",
        "Temporary disability income: 50% of monthly salary (up to 12 months)",
        "Hospital cash: KES 2,000/day (up to 60 days)",
        "Home contents (theft, fire, malicious damage): KES 500,000",
        "Personal liability: KES 1,000,000",
        "Critical illness (10 conditions): KES 500,000",
        "24/7 emergency assistance hotline"
      ]
    },
    "amani_family" => %{
      name: "Amani Shield Family",
      icon: "",
      annual_premium: 32_000,
      description:
        "Comprehensive family bundled plan covering all household members under " <>
        "one policy. Includes personal accident for the entire family, home " <>
        "contents, personal liability, and a school fees protection benefit " <>
        "if the principal member suffers permanent disability or death.",
      pa_death:          3_000_000,
      pa_disability:     3_000_000,
      pa_medical:          200_000,
      home_contents:     1_000_000,
      personal_liab:     2_000_000,
      critical_illness:  1_000_000,
      benefits: [
        "Accidental death (principal): KES 3,000,000",
        "Permanent disability (principal): KES 3,000,000",
        "PA cover for spouse and children included",
        "Emergency medical (accident): KES 200,000",
        "Home contents (theft, fire, flood, malicious): KES 1,000,000",
        "Personal liability: KES 2,000,000",
        "Critical illness: KES 1,000,000",
        "School fees protection benefit: up to KES 500,000",
        "24/7 family emergency assistance"
      ]
    }
  }

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
    plan_key   = socket.assigns.selected_plan
    plan       = @plans[plan_key]
    age        = parse_int(params["age"])
    occupation = params["occupation"] || "office"

    # Occupation loading for PA component
    occ_loading =
      case occupation do
        "manual_light"  -> 1.15
        "manual_heavy"  -> 1.30
        "construction"  -> 1.50
        _               -> 1.00
      end

    # Age loading: +10% for ages 50+, +20% for ages 60+
    age_loading =
      cond do
        age >= 60 -> 1.20
        age >= 50 -> 1.10
        true      -> 1.00
      end

    base_premium = plan.annual_premium
    loaded       = round(base_premium * occ_loading * age_loading)
    ira_levy     = round(loaded * 0.0025)
    stamp        = 40
    total        = loaded + ira_levy + stamp

    quote_data = %{
      plan:         plan.name,
      age:          age,
      occupation:   occupation,
      base_premium: base_premium,
      loaded:       loaded,
      ira_levy:     ira_levy,
      stamp:        stamp,
      total:        total,
      monthly:      div(total, 12),
      pa_death:     plan.pa_death,
      pa_disability: plan.pa_disability,
      home_contents: plan.home_contents
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
          plan_name:            "Amani Shield – #{qd.plan}",
          email:                user.email,
          plan_type:            "amani_shield",
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

  def plans, do: @plans

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

  defp parse_int(nil), do: 30
  defp parse_int(""), do: 30
  defp parse_int(val) do
    case Integer.parse(to_string(val)) do
      {n, _} -> max(n, 1)
      :error  -> 30
    end
  end
end
