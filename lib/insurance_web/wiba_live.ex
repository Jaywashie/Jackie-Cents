defmodule InsuranceWeb.WibaLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  # WIBA (Work Injury Benefits Act) premium rates
  # Under the Work Injury Benefits Act (WIBA) Cap 236 Laws of Kenya
  #
  # Premium = Gross Annual Payroll × Occupational Rate × Employer Liability Factor
  #
  # Occupational risk rates by category (% of annual payroll)
  # Source: WIBA Schedule of Rates, IRA Kenya
  @wiba_rates %{
    "clerical"       => %{label: "Clerical / Administrative",           rate: 0.0050, description: "Office-based workers: clerks, accountants, receptionists, data entry staff."},
    "sales_driver"   => %{label: "Sales Representative / Driver",       rate: 0.0100, description: "Field sales, delivery drivers, rider/courier staff with road exposure."},
    "artisan"        => %{label: "Artisan / Skilled Trade",             rate: 0.0150, description: "Plumbers, electricians, carpenters, mechanics, welders."},
    "supervisor"     => %{label: "Supervisor / Foreman",                rate: 0.0175, description: "Supervisory roles on site or in workshops with partial manual activity."},
    "labourer"       => %{label: "General Labourer / Unskilled",        rate: 0.0200, description: "General manual workers, cleaners, porters, watchmen."},
    "construction"   => %{label: "Construction / Civil Works",          rate: 0.0300, description: "Construction site workers, scaffolders, masons, demolition crew."},
    "mining"         => %{label: "Mining / Quarrying",                  rate: 0.0400, description: "Quarry workers, drillers, blasters, underground mine workers."},
    "security"       => %{label: "Security Guard / Cash-in-Transit",    rate: 0.0250, description: "Uniformed security guards, armed escorts, cash-in-transit crew."},
    "hospitality"    => %{label: "Hospitality / Hotel / Restaurant",    rate: 0.0100, description: "Cooks, waiters, housekeeping, hotel maintenance staff."},
    "agri_light"     => %{label: "Agriculture — Light (Tea / Flowers)", rate: 0.0150, description: "Tea pickers, flower farm workers, light agricultural labour."},
    "agri_heavy"     => %{label: "Agriculture — Heavy (Machinery)",     rate: 0.0250, description: "Tractor operators, combine harvester operators, irrigation workers."},
    "healthcare"     => %{label: "Healthcare / Medical Staff",          rate: 0.0120, description: "Nurses, clinical officers, lab technicians, hospital support staff."},
    "it_tech"        => %{label: "IT / Technology / Telecoms",          rate: 0.0060, description: "Software developers, network engineers, telecommunications field staff."},
    "transport"      => %{label: "Transport / Logistics / PSV",         rate: 0.0200, description: "Bus drivers, matatu operators, truck drivers, flight crew."},
    "manufacturing"  => %{label: "Manufacturing / Factory Worker",      rate: 0.0225, description: "Machine operators, assembly line workers, packaging staff."}
  }

  # Employer's Liability extension (optional, adds flat % to base WIBA premium)
  @el_loading 0.25  # 25% additional of WIBA premium

  # Statutory minimum compensation (WIBA 2007 as amended)
  @min_compensation 960_000   # KES 960,000 (96 months × KES 10,000 earnings for low-wage workers)
  @min_annual_earning 72_000  # KES 72,000 (minimum assumed annual earning for cap purposes)

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
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
        occupation_key  = params["occupation"] || "clerical"
        employees       = parse_int(params["employees"])
        annual_payroll  = parse_int(params["annual_payroll"])
        include_el      = params["include_el"] == "true"

        occupation_data = @wiba_rates[occupation_key] || @wiba_rates["clerical"]
        rate            = occupation_data.rate

        # WIBA Premium = Payroll × Rate
        wiba_premium = round(annual_payroll * rate)

        # Employer's Liability extension (optional)
        el_premium = if include_el, do: round(wiba_premium * @el_loading), else: 0

        # IRA Levy: 0.25% of net premium
        base_premium  = wiba_premium + el_premium
        ira_levy      = round(base_premium * 0.0025)
        phcf_levy     = round(base_premium * 0.0025)  # Post Hardship Compensation Fund
        stamp_duty    = 40  # KES 40 flat stamp duty
        total_premium = base_premium + ira_levy + phcf_levy + stamp_duty

        # Average earnings per employee
        avg_annual_earning = if employees > 0, do: div(annual_payroll, employees), else: @min_annual_earning
        avg_annual_earning = max(avg_annual_earning, @min_annual_earning)

        # Statutory benefit calculations (WIBA 2007)
        # Death/total disability: 96 months × avg monthly earnings (max 96 months)
        avg_monthly_earning   = div(avg_annual_earning, 12)
        max_death_benefit     = max(96 * avg_monthly_earning, @min_compensation)
        # Temporary disability: 50% of monthly earnings (up to 12 months)
        temp_disability_monthly = div(avg_monthly_earning, 2)
        # Medical expenses limit per incident: no statutory cap (reasonable & necessary)

        quote_data = %{
          occupation:             occupation_data.label,
          employees:              employees,
          annual_payroll:         annual_payroll,
          rate_percent:           Float.round(rate * 100, 2),
          wiba_premium:           wiba_premium,
          el_premium:             el_premium,
          ira_levy:               ira_levy,
          phcf_levy:              phcf_levy,
          stamp_duty:             stamp_duty,
          total_annual:           total_premium,
          monthly:                div(total_premium, 12),
          include_el:             include_el,
          max_death_benefit:      max_death_benefit,
          temp_disability_monthly: temp_disability_monthly,
          avg_monthly_earning:    avg_monthly_earning
        }

        {:noreply, assign(socket, quote: total_premium, quote_data: quote_data, saved: false, show_login_prompt: false)}
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
          plan_name:            "WIBA – #{qd.occupation}",
          email:                user.email,
          plan_type:            "wiba",
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

          {:error, _reason} ->
            {:noreply, put_flash(socket, :error, "Failed to save quote. Please try again.")}
        end
    end
  end

  def wiba_rates, do: @wiba_rates

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
