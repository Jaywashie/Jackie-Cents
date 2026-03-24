defmodule InsuranceWeb.UnitTrustLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  # Unit Trust Fund types with risk profiles, indicative returns, and fees
  @ut_funds %{
    "equity"       => %{label: "Equity Fund",          risk: "High",   indicative_rate: 0.18, management_fee: 0.025, min_amount: 5_000,  description: "Invests primarily in listed equities at the Nairobi Securities Exchange (NSE). Best for long-term investors (5+ years) seeking capital growth."},
    "balanced"     => %{label: "Balanced Fund",        risk: "Medium", indicative_rate: 0.14, management_fee: 0.020, min_amount: 5_000,  description: "A mix of equities and fixed-income securities. Suitable for medium-term investors seeking growth with moderate risk."},
    "bond"         => %{label: "Bond Fund",            risk: "Low",    indicative_rate: 0.12, management_fee: 0.015, min_amount: 5_000,  description: "Invests in government and corporate bonds. Suitable for conservative investors seeking regular income."},
    "income"       => %{label: "Income Fund",          risk: "Low",    indicative_rate: 0.11, management_fee: 0.015, min_amount: 5_000,  description: "Focuses on fixed-income instruments — treasury bills, bonds, and bank deposits. Ideal for capital preservation with steady income."},
    "sharia"       => %{label: "Sharia Compliant Fund",risk: "Medium", indicative_rate: 0.13, management_fee: 0.020, min_amount: 5_000,  description: "An ethically screened, Sharia-compliant portfolio for investors seeking Halal investment options."}
  }

  # Investor risk profiles
  @risk_profiles %{
    "conservative"  => %{label: "Conservative",  description: "Capital preservation. Prefer low-risk instruments."},
    "moderate"      => %{label: "Moderate",       description: "Balance between growth and safety."},
    "aggressive"    => %{label: "Aggressive",     description: "Maximum growth. Comfortable with volatility."}
  }

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       selected_fund: nil,
       risk_profile: "moderate",
       quote: nil,
       quote_data: nil,
       saved: false,
       show_login_prompt: false
     )}
  end

  def handle_event("select_fund", %{"fund" => fund}, socket) do
    {:noreply, assign(socket, selected_fund: fund, quote: nil, quote_data: nil, saved: false)}
  end

  def handle_event("generate_quote", params, socket) do
    case socket.assigns.current_user do
      nil ->
        {:noreply, assign(socket, show_login_prompt: true)}

      _user ->
        fund_key      = params["fund_key"] || socket.assigns.selected_fund
        lump_sum      = parse_float(params["lump_sum"])
        monthly_top   = parse_float(params["monthly_topup"])
        goal_years    = parse_int(params["goal_years"])

        fund_data = @ut_funds[fund_key] || @ut_funds["balanced"]
        rate      = fund_data.indicative_rate
        mgmt_fee  = fund_data.management_fee
        net_rate  = rate - mgmt_fee
        years     = max(goal_years, 1)

        # Lump sum grows as: lump_sum * (1 + net_rate)^years
        lump_sum_fv = lump_sum * :math.pow(1 + net_rate, years)

        # Monthly top-up annuity: FV = PMT * [((1+r)^n - 1) / r]  monthly compounding
        monthly_rate = net_rate / 12
        n_months     = years * 12

        monthly_fv =
          if monthly_rate > 0 do
            monthly_top * ((:math.pow(1 + monthly_rate, n_months) - 1) / monthly_rate)
          else
            monthly_top * n_months
          end

        projected_value  = lump_sum_fv + monthly_fv
        total_invested   = lump_sum + (monthly_top * 12 * years)
        total_returns    = projected_value - total_invested

        quote_data = %{
          fund:             fund_data.label,
          risk:             fund_data.risk,
          lump_sum:         round(lump_sum),
          monthly_topup:    round(monthly_top),
          indicative_rate:  rate * 100,
          management_fee:   mgmt_fee * 100,
          net_rate:         Float.round(net_rate * 100, 1),
          goal_years:       years,
          projected_value:  round(projected_value),
          total_invested:   round(total_invested),
          total_returns:    round(total_returns)
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
          plan_name:            "Unit Trust – #{qd.fund}",
          email:                user.email,
          plan_type:            "unit_trust",
          monthly_contribution: qd.monthly_topup,
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

  def ut_funds,      do: @ut_funds
  def risk_profiles, do: @risk_profiles

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

  def risk_color("High"),   do: "text-red-600 bg-red-50"
  def risk_color("Medium"), do: "text-yellow-600 bg-yellow-50"
  def risk_color("Low"),    do: "text-green-600 bg-green-50"
  def risk_color(_),        do: "text-gray-600 bg-gray-50"

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
