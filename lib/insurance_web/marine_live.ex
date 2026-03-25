defmodule InsuranceWeb.MarineLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  # Marine Insurance Plans
  # Covers goods in transit (import/export) and marine hull
  # Rates are based on standard IRA Kenya / Institute Cargo Clauses

  @plans %{
    "cargo_icc_a" => %{
      name: "Marine Cargo – ICC (A) All Risks",
      icon: "",
      rate: 0.0060,
      min_premium: 5_000,
      description:
        "The widest cargo cover under Institute Cargo Clauses (A). Covers all risks of " <>
        "physical loss or damage to insured goods during transit by sea, air, or road. " <>
        "Suitable for high-value imports/exports, electronics, machinery, and general merchandise.",
      benefits: [
        "All risks of physical loss or damage (ICC A)",
        "Sea, air, road, and inland waterway transit",
        "Loading and unloading cover",
        "General average and salvage charges",
        "War and strikes extension available",
        "New-for-old replacement for total loss",
        "Survey and claims handling in Kenya"
      ]
    },
    "cargo_icc_c" => %{
      name: "Marine Cargo – ICC (C) Named Perils",
      icon: "",
      rate: 0.0035,
      min_premium: 3_500,
      description:
        "Named-perils cover under Institute Cargo Clauses (C). Covers fire, explosion, " <>
        "stranding, sinking, overturning, collision, and general average sacrifice. " <>
        "A cost-effective option for bulk cargo, raw materials, and lower-risk commodities.",
      benefits: [
        "Fire and explosion",
        "Vessel stranding, grounding, sinking, or capsizing",
        "Overturning or derailment of land conveyance",
        "Collision or contact with external object",
        "General average sacrifice and salvage charges",
        "Discharge at port of distress",
        "Survey and claims handling in Kenya"
      ]
    },
    "open_cover" => %{
      name: "Open Marine Cover (Annual Declaration)",
      icon: "",
      rate: 0.0050,
      min_premium: 30_000,
      description:
        "An annual open cover policy for businesses with frequent shipments. " <>
        "Declare each shipment as it occurs — premiums calculated per declaration. " <>
        "Ideal for importers, exporters, clearing agents, and manufacturers.",
      benefits: [
        "Covers all shipments declared during the policy year",
        "ICC (A) or ICC (C) terms — as agreed",
        "No need to arrange cover per shipment",
        "Monthly or quarterly declaration statements",
        "Automatic cover for shipments in transit at policy inception",
        "Competitive annual rates vs. per-shipment basis",
        "Single certificate issued per consignment"
      ]
    },
    "marine_hull" => %{
      name: "Marine Hull & Machinery",
      icon: "",
      rate: 0.0150,
      min_premium: 50_000,
      description:
        "Covers physical damage to vessels including fishing boats, lake vessels, " <>
        "river craft, ferries, and pleasure craft. Includes hull, machinery, " <>
        "equipment, and third-party liability on Kenyan inland waters and coastal areas.",
      benefits: [
        "Hull and machinery damage (collision, fire, grounding)",
        "Machinery breakdown and engine damage",
        "P&I (Protection & Indemnity) for third-party liability",
        "Salvage and towage costs",
        "Crew personal accident extension available",
        "Total loss — agreed vessel value",
        "Covers Lake Victoria, Indian Ocean coast, and inland rivers"
      ]
    }
  }

  @cargo_types [
    "General Merchandise",
    "Electronics / Technology",
    "Machinery & Equipment",
    "Raw Materials / Commodities",
    "Foodstuffs / Perishables",
    "Pharmaceuticals / Medical Supplies",
    "Vehicles / Spare Parts",
    "Textiles / Clothing",
    "Construction Materials",
    "Other"
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
    plan_key   = socket.assigns.selected_plan
    plan       = @plans[plan_key]
    cargo_val  = parse_int(params["cargo_value"])

    base_premium = round(cargo_val * plan.rate)
    premium      = max(base_premium, plan.min_premium)

    # War & strikes extension: +0.025% of cargo value
    war_ext      = if params["war_extension"] == "true", do: round(cargo_val * 0.00025), else: 0
    # SRCC extension: +0.015%
    srcc_ext     = if params["srcc_extension"] == "true", do: round(cargo_val * 0.00015), else: 0

    ira_levy  = round((premium + war_ext + srcc_ext) * 0.0025)
    stamp     = 40
    total     = premium + war_ext + srcc_ext + ira_levy + stamp

    quote_data = %{
      plan:        plan.name,
      cargo_value: cargo_val,
      rate:        plan.rate * 100,
      base:        premium,
      war_ext:     war_ext,
      srcc_ext:    srcc_ext,
      ira_levy:    ira_levy,
      stamp:       stamp,
      total:       total
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
          plan_name:            "Marine Insurance – #{qd.plan}",
          email:                user.email,
          plan_type:            "marine",
          monthly_contribution: 0,
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

  def plans,       do: @plans
  def cargo_types, do: @cargo_types

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

  def format_rate(r) when is_float(r), do: :erlang.float_to_binary(r, decimals: 2)
  def format_rate(_), do: "0.00"

  defp parse_int(nil), do: 0
  defp parse_int(""), do: 0
  defp parse_int(val) do
    case Integer.parse(to_string(val)) do
      {n, _} -> n
      :error  -> 0
    end
  end
end
