defmodule InsuranceWeb.MotorLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  # Britam comprehensive premium rates (Kenya market standard):
  # - Vehicles ≤ KES 2,500,000 → 4.25% of value (min KES 30,180)
  # - Vehicles > KES 2,500,000 → 3.50% of value
  # Third party only → statutory minimum: KES 7,560/year (private), KES 13,440 (commercial)
  # Age loading: vehicles > 5 years attract +0.5% of value per additional year (capped at 3%)
  # Usage loading: commercial use attracts +25% on base rate

  @impl true
  def mount(_params, _session, socket) do
    plans = [
      %{
        id: "comprehensive",
        name: "Motor Comprehensive",
        icon: "",
        min_premium: 30_180,
        description:
          "Full protection covering accidental damage, fire, theft, malicious damage, and third-party liabilities. " <>
          "Britam's Motiflex option allows flexible monthly, quarterly, or semi-annual premium payments. " <>
          "Geographical scope is Kenya, extendable to other East African countries on request.",
        benefits: [
          "Accidental damage & overturning",
          "Fire & theft (subject to excess)",
          "Malicious damage cover",
          "Free windscreen & audio/video accessories cover",
          "Third-party bodily injury & property damage",
          "Total loss: repairs exceeding 50% of sum insured",
          "Flexible payment via Britam Motiflex"
        ]
      },
      %{
        id: "third_party",
        name: "Third Party Only",
        icon: "",
        min_premium: 7_560,
        description:
          "Minimum statutory cover required under the Traffic Act, Chapter 403 of the Laws of Kenya. " <>
          "Covers legal liability for bodily injury or death of third parties and accidental damage to " <>
          "third-party property. Does not cover your own vehicle against damage, fire, or theft.",
        benefits: [
          "Third-party bodily injury & death liability",
          "Third-party property damage",
          "Legal defence costs",
          "Meets statutory IRA & Traffic Act requirements",
          "Most affordable motor cover option"
        ]
      }
    ]

    {:ok,
     socket
     |> assign(:plans, plans)
     |> assign(:selected_plan, nil)
     |> assign(:quote, nil)
     |> assign(:loading, false)
     |> assign(:saved, false)
     |> assign(:vehicle_value, nil)
     |> assign(:quote_form, to_form(%{"vehicle_value" => "", "vehicle_age" => "", "usage" => ""}))}
  end

  @impl true
  def handle_event("select_plan", %{"id" => plan_id}, socket) do
    {:noreply, assign(socket, selected_plan: plan_id, quote: nil, saved: false)}
  end

  @impl true
  def handle_event("generate_quote", params, socket) do
    send(self(), {:calculate_quote, params})
    {:noreply, assign(socket, loading: true)}
  end

  @impl true
  def handle_info({:calculate_quote, params}, socket) do
    value   = parse_int(params["vehicle_value"])
    age     = parse_int(params["vehicle_age"])
    usage   = params["usage"] || "private"

    quote =
      case socket.assigns.selected_plan do
        "comprehensive" ->
          # Step 1: base rate by value band
          base_rate = if value <= 2_500_000, do: 0.0425, else: 0.035
          base      = round(value * base_rate)

          # Step 2: vehicle age loading — +0.5% per year beyond 5 yrs, capped at +3%
          age_loading_pct = min((max(age - 5, 0)) * 0.005, 0.03)
          age_load        = round(value * age_loading_pct)

          # Step 3: commercial use loading +25% on base
          usage_load = if usage == "commercial", do: round(base * 0.25), else: 0

          raw = base + age_load + usage_load
          # Enforce Britam minimum premium
          max(raw, 30_180)

        "third_party" ->
          # Statutory minimum: KES 7,560 private / KES 13,440 commercial
          base = if usage == "commercial", do: 13_440, else: 7_560
          # Third party has no vehicle-value-based loading — flat statutory rate
          base

        _ -> 0
      end

    {:noreply,
     socket
     |> assign(quote: quote, loading: false, vehicle_value: value, saved: false)}
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
        plan_name =
          case socket.assigns.selected_plan do
            "comprehensive" -> "Britam Motor Comprehensive Insurance"
            "third_party"   -> "Britam Third Party Motor Insurance"
            _               -> "Motor Insurance"
          end

        quote_val = socket.assigns.quote || 0

        quote_params = %{
          user_id:              user.id,
          plan_name:            plan_name,
          email:                user.email,
          plan_type:            "motor",
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
            {:noreply, socket |> assign(saved: true) |> put_flash(:info, "Quote saved!")}

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

  defp safe_monthly(0), do: 0
  defp safe_monthly(n), do: div(n, 12)

  defp parse_int(nil), do: 0
  defp parse_int(""), do: 0
  defp parse_int(val) when is_binary(val) do
    case Integer.parse(val) do
      {n, _} -> n
      :error  -> 0
    end
  end
  defp parse_int(val) when is_integer(val), do: val
  defp parse_int(_), do: 0
end
