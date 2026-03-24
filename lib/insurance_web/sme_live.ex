defmodule InsuranceWeb.SmeLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  # SME Cover types with base rates as % of sum insured / payroll
  # Fire & Perils: ~0.35% of sum insured
  # Burglary:      ~0.50% of sum insured
  # Public Liability: flat rate bands by turnover
  # Group Personal Accident: per employee per year
  # Business Interruption: ~0.25% of indemnity period value
  # SME Shield (combined):  ~0.60% of sum insured

  @sme_covers %{
    "fire_perils"    => %{label: "Fire & Perils",              base_rate: 0.0035, description: "Covers your business premises, stock, and equipment against fire, lightning, explosion, and allied perils."},
    "burglary"       => %{label: "Burglary & Theft",           base_rate: 0.0050, description: "Covers loss of stock, cash, and business assets due to break-in, theft with violent entry, and hold-up."},
    "public_liability" => %{label: "Public Liability",         base_rate: nil,    description: "Covers your legal liability to third parties for bodily injury or property damage arising from your business operations."},
    "gpa"            => %{label: "Group Personal Accident",    base_rate: 0.0120, description: "Covers all your employees for accidental death, permanent disability, and medical expenses arising from workplace or off-duty accidents."},
    "business_int"   => %{label: "Business Interruption",      base_rate: 0.0025, description: "Covers loss of gross profit and continuing fixed charges if business operations are disrupted by an insured peril."},
    "sme_shield"     => %{label: "SME Shield (Combined Cover)",base_rate: 0.0060, description: "A comprehensive packaged cover combining Fire & Perils, Burglary, Public Liability, and Employer's Liability into one policy — ideal for SMEs."}
  }

  # Public liability flat rates by annual turnover band (KES)
  @pl_rates [
    {5_000_000,   8_500},
    {10_000_000,  14_000},
    {20_000_000,  22_000},
    {50_000_000,  40_000},
    {100_000_000, 70_000}
  ]

  # Business sectors for risk loading
  @sectors %{
    "retail"       => %{label: "Retail Shop / Supermarket",    loading: 1.00},
    "hospitality"  => %{label: "Hotel / Restaurant / Bar",     loading: 1.20},
    "manufacturing"=> %{label: "Manufacturing / Workshop",     loading: 1.30},
    "office"       => %{label: "Professional Office / Agency", loading: 0.90},
    "salon"        => %{label: "Salon / Spa / Beauty",         loading: 1.00},
    "pharmacy"     => %{label: "Pharmacy / Medical Clinic",    loading: 1.10},
    "school"       => %{label: "School / Training Centre",     loading: 1.05},
    "logistics"    => %{label: "Logistics / Warehouse",        loading: 1.25},
    "construction" => %{label: "Construction / Contractor",    loading: 1.40},
    "tech"         => %{label: "IT / Tech / Consulting",       loading: 0.85},
    "agri"         => %{label: "Agriculture / Agribusiness",   loading: 1.10},
    "other"        => %{label: "Other",                        loading: 1.00}
  }

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       selected_cover: nil,
       quote: nil,
       quote_data: nil,
       saved: false,
       show_login_prompt: false
     )}
  end

  def handle_event("select_cover", %{"cover" => cover}, socket) do
    {:noreply, assign(socket, selected_cover: cover, quote: nil, quote_data: nil, saved: false)}
  end

  def handle_event("generate_quote", params, socket) do
    case socket.assigns.current_user do
      nil ->
        {:noreply, assign(socket, show_login_prompt: true)}

      _user ->
        cover_key   = params["cover_key"] || socket.assigns.selected_cover
        cover_data  = @sme_covers[cover_key] || @sme_covers["sme_shield"]
        sector_key  = params["sector"] || "retail"
        sector_data = @sectors[sector_key] || @sectors["retail"]
        loading     = sector_data.loading

        annual_premium =
          case cover_key do
            "public_liability" ->
              turnover = parse_int(params["turnover"])
              pl_flat_rate(turnover)

            "gpa" ->
              employees       = parse_int(params["employees"])
              capital_per_emp = parse_int(params["capital_per_employee"])
              base            = cover_data.base_rate * capital_per_emp * employees
              round(base * loading)

            _ ->
              sum_insured = parse_int(params["sum_insured"])
              base        = cover_data.base_rate * sum_insured
              round(base * loading)
          end

        # Minimum premium: KES 5,000 for all SME covers
        annual_premium = max(annual_premium, 5_000)
        # Stamp duty + levy: 0.2% of premium (regulatory)
        levy        = round(annual_premium * 0.002)
        total       = annual_premium + levy

        quote_data = %{
          cover:          cover_data.label,
          sector:         sector_data.label,
          loading:        loading,
          base_premium:   annual_premium,
          levy:           levy,
          total_annual:   total,
          monthly:        div(total, 12)
        }

        {:noreply, assign(socket, quote: total, quote_data: quote_data, saved: false, show_login_prompt: false)}
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
          plan_name:            "SME Insurance – #{qd.cover}",
          email:                user.email,
          plan_type:            "sme",
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

  def sme_covers, do: @sme_covers
  def sectors,    do: @sectors

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

  defp pl_flat_rate(turnover) do
    {_limit, rate} =
      Enum.find(@pl_rates, List.last(@pl_rates), fn {limit, _rate} -> turnover <= limit end)
    rate
  end

  defp parse_int(nil), do: 0
  defp parse_int(""), do: 0
  defp parse_int(val) do
    case Integer.parse(to_string(val)) do
      {n, _} -> n
      :error  -> 0
    end
  end
end
