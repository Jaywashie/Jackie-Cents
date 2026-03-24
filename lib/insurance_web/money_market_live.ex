defmodule InsuranceWeb.MoneyMarketLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  # Money Market Fund tiers based on investment amount ranges
  # Returns are indicative - based on typical MMF yields (12–14% p.a.)
  @mmf_tiers %{
    "starter"    => %{label: "Starter",    min_amount: 1_000,     indicative_rate: 0.10, management_fee: 0.015},
    "growth"     => %{label: "Growth",     min_amount: 10_000,    indicative_rate: 0.11, management_fee: 0.014},
    "premium"    => %{label: "Premium",    min_amount: 50_000,    indicative_rate: 0.12, management_fee: 0.013},
    "elite"      => %{label: "Elite",      min_amount: 250_000,   indicative_rate: 0.13, management_fee: 0.012},
    "corporate"  => %{label: "Corporate",  min_amount: 1_000_000, indicative_rate: 0.14, management_fee: 0.010}
  }

  # Investment frequencies
  @frequencies %{
    "once"    => %{label: "Lump Sum (Once-off)",  multiplier: 1},
    "monthly" => %{label: "Monthly",               multiplier: 12},
    "quarterly"=> %{label: "Quarterly",            multiplier: 4},
    "annually"=> %{label: "Annually",              multiplier: 1}
  }

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       mmf_tier: "growth",
       frequency: "monthly",
       quote: nil,
       quote_data: nil,
       saved: false,
       show_login_prompt: false
     )}
  end

  def handle_event("generate_quote", params, socket) do
    case socket.assigns.current_user do
      nil ->
        {:noreply, assign(socket, show_login_prompt: true)}

      _user ->
        amount        = parse_float(params["amount"])
        tier_key      = params["mmf_tier"] || socket.assigns.mmf_tier
        frequency_key = params["frequency"] || socket.assigns.frequency
        goal_years    = parse_int(params["goal_years"])

        tier_data = @mmf_tiers[tier_key] || @mmf_tiers["growth"]
        freq_data = @frequencies[frequency_key] || @frequencies["monthly"]

        # Annual investment amount
        annual_investment =
          case frequency_key do
            "once"      -> amount
            "monthly"   -> amount * 12
            "quarterly" -> amount * 4
            "annually"  -> amount
            _           -> amount * 12
          end

        rate         = tier_data.indicative_rate
        mgmt_fee     = tier_data.management_fee
        net_rate     = rate - mgmt_fee
        years        = max(goal_years, 1)

        # Future value of regular annuity (end-of-period)
        # FV = P * [((1 + r)^n - 1) / r]  where P = annual_investment, r = net_rate, n = years
        projected_value =
          if net_rate > 0 do
            annual_investment * ((:math.pow(1 + net_rate, years) - 1) / net_rate)
          else
            annual_investment * years
          end

        total_invested   = annual_investment * years
        total_returns    = projected_value - total_invested
        annual_interest  = round(total_invested * rate)

        quote_data = %{
          tier:             tier_data.label,
          frequency:        freq_data.label,
          amount:           round(amount),
          annual_investment: round(annual_investment),
          indicative_rate:  rate * 100,
          management_fee:   mgmt_fee * 100,
          net_rate:         net_rate * 100,
          goal_years:       years,
          projected_value:  round(projected_value),
          total_invested:   round(total_invested),
          total_returns:    round(total_returns),
          annual_interest:  annual_interest
        }

        {:noreply, assign(socket, quote: round(projected_value), quote_data: quote_data, saved: false, show_login_prompt: false)}
    end
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
          plan_name:            "Money Market Fund – #{qd.tier}",
          email:                user.email,
          plan_type:            "money_market",
          monthly_contribution: round(qd.annual_investment / 12),
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

  def mmf_tiers,  do: @mmf_tiers
  def frequencies, do: @frequencies

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

  def format_percent(f) when is_float(f), do: :erlang.float_to_binary(f, decimals: 1)
  def format_percent(_), do: "0.0"

  defp parse_int(nil), do: 1
  defp parse_int(""), do: 1
  defp parse_int(val) do
    case Integer.parse(to_string(val)) do
      {n, _} -> max(n, 1)
      :error  -> 1
    end
  end

  defp parse_float(nil), do: 0.0
  defp parse_float(""), do: 0.0
  defp parse_float(val) do
    case Float.parse(to_string(val)) do
      {f, _} -> f
      :error  -> 0.0
    end
  end
end
