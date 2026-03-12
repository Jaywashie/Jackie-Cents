defmodule InsuranceWeb.MedicalLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  # Milele base rates per plan tier (annual, individual, inpatient only)
  # Tiers: essential (300k IP), bronze (500k IP), silver (1M IP), gold (2M IP), platinum (10M IP)
  @milele_tiers %{
    "essential"  => %{label: "Milele Essential",  inpatient_limit: 300_000,    base_annual: 12_000},
    "bronze"     => %{label: "Milele Bronze",     inpatient_limit: 500_000,    base_annual: 18_000},
    "silver"     => %{label: "Milele Silver",     inpatient_limit: 1_000_000,  base_annual: 28_000},
    "gold"       => %{label: "Milele Gold",       inpatient_limit: 2_000_000,  base_annual: 45_000},
    "platinum"   => %{label: "Milele Platinum",   inpatient_limit: 10_000_000, base_annual: 90_000}
  }

  # Bima ya Mwananchi – 5 benefit options (inpatient shared family limits)
  # Option premiums for principal member (no dependants), per official schedule
  @bym_options %{
    "option1" => %{label: "Option 1", inpatient_limit: 75_000,  base_annual: 4_600},
    "option2" => %{label: "Option 2", inpatient_limit: 100_000, base_annual: 6_200},
    "option3" => %{label: "Option 3", inpatient_limit: 150_000, base_annual: 8_000},
    "option4" => %{label: "Option 4", inpatient_limit: 200_000, base_annual: 10_500},
    "option5" => %{label: "Option 5", inpatient_limit: 300_000, base_annual: 14_200}
  }

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       selected_plan: nil,
       milele_tier: "silver",
       bym_option: "option1",
       quote: nil,
       saved: false
     )}
  end

  def handle_event("select_plan", %{"plan" => plan}, socket) do
    {:noreply, assign(socket, selected_plan: plan, quote: nil, saved: false)}
  end

  def handle_event("generate_quote", params, socket) do
    age        = parse_int(params["age"])
    dependants = parse_int(params["dependants"])

    quote =
      case socket.assigns.selected_plan do
        "milele" ->
          tier      = params["milele_tier"] || socket.assigns.milele_tier
          tier_data = @milele_tiers[tier] || @milele_tiers["silver"]
          base      = tier_data.base_annual
          # Age loading: +3% of base per year above 35; copay for senior entry (55+) adds flat loading
          age_loading  = if age > 35, do: round(base * 0.03 * (age - 35)), else: 0
          senior_load  = if age >= 55, do: round(base * 0.20), else: 0
          dep_premium  = dependants * round(base * 0.60)
          base + age_loading + senior_load + dep_premium

        "mwananchi" ->
          option      = params["bym_option"] || socket.assigns.bym_option
          option_data = @bym_options[option] || @bym_options["option1"]
          base        = option_data.base_annual
          # Additional dependants: ~KES 2,400 each (per Britam schedule)
          dep_premium = dependants * 2_400
          base + dep_premium

        _ ->
          0
      end

    {:noreply, assign(socket, quote: quote, saved: false)}
  end

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
            "milele"    -> "Britam Milele Health Plan"
            "mwananchi" -> "Britam Bima ya Mwananchi"
            _           -> "Medical Plan"
          end

        quote_val = socket.assigns.quote || 0

        quote_params = %{
          user_id:              user.id,
          plan_name:            plan_name,
          email:                user.email,
          plan_type:            "medical",
          monthly_contribution: safe_monthly(quote_val),
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

  def milele_tiers, do: @milele_tiers
  def bym_options,  do: @bym_options

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

  defp safe_monthly(0), do: 0
  defp safe_monthly(n), do: div(n, 12)

  defp parse_int(nil), do: 0
  defp parse_int(""), do: 0
  defp parse_int(val) do
    case Integer.parse(to_string(val)) do
      {n, _} -> n
      :error  -> 0
    end
  end
end
