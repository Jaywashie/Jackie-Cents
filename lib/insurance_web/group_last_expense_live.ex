defmodule InsuranceWeb.GroupLastExpenseLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  # Group Last Expense (Funeral) Cover
  # Pays a lump sum within 48 hours of death to cover funeral costs
  # Kenya market rates: ~1.0% – 2.0% of sum insured per member per year
  # Covers principal member, spouse, children, and extended family (parents/in-laws)

  @cover_levels [
    {"50k",   "KES 50,000",   50_000,  0.0180},
    {"100k",  "KES 100,000", 100_000,  0.0160},
    {"150k",  "KES 150,000", 150_000,  0.0150},
    {"200k",  "KES 200,000", 200_000,  0.0140},
    {"300k",  "KES 300,000", 300_000,  0.0130},
    {"500k",  "KES 500,000", 500_000,  0.0120}
  ]

  @member_types [
    {"principal",               "Principal Only",                       1},
    {"principal_spouse",        "Principal + Spouse",                   2},
    {"principal_spouse_2kids",  "Principal + Spouse + 2 Children",      4},
    {"principal_spouse_4kids",  "Principal + Spouse + 4 Children",      6},
    {"family_extended",         "Family + 2 Parents / Parents-in-Law",  8}
  ]

  @plans %{
    "last_expense_basic" => %{
      name: "Group Last Expense Basic",
      icon: "",
      description:
        "An affordable group funeral expense policy providing a guaranteed lump sum " <>
        "payment within 48 hours of a member's death. Covers the principal member, " <>
        "spouse, and dependent children. No medical underwriting required for groups " <>
        "of 10 or more members. Minimum group size: 10.",
      benefits: [
        "Guaranteed payout within 48 hours of claim",
        "Covers principal, spouse, and children",
        "No individual medical underwriting (groups 10+)",
        "Cover from KES 50,000 to KES 300,000 per life",
        "Minimum group size: 10 members",
        "Annual renewable policy",
        "Straightforward claims process"
      ]
    },
    "last_expense_plus" => %{
      name: "Group Last Expense Plus",
      icon: "",
      description:
        "Enhanced group last expense cover extending benefits to parents and in-laws. " <>
        "Includes a grief counselling session and repatriation of remains within Kenya. " <>
        "Higher sum assured options up to KES 500,000. Ideal for saccos, employers, " <>
        "chamas, churches, and community groups.",
      benefits: [
        "Guaranteed payout within 48 hours of claim",
        "Covers principal, spouse, children, parents & in-laws",
        "Grief counselling: up to 3 sessions per claim",
        "Repatriation of remains within Kenya",
        "Cover from KES 100,000 to KES 500,000 per life",
        "No individual medicals (groups 10+)",
        "Annual renewable policy",
        "Group wellness benefit included"
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
    plan_key    = socket.assigns.selected_plan
    plan        = @plans[plan_key]
    members     = parse_int(params["members"])
    cover_key   = params["cover_level"] || "100k"
    member_type = params["member_type"] || "principal"

    {_, cover_label, sum_insured, rate} =
      Enum.find(@cover_levels, {"100k", "KES 100,000", 100_000, 0.016}, fn {k, _, _, _} -> k == cover_key end)

    {_, type_label, lives_per_member} =
      Enum.find(@member_types, {"principal", "Principal", 1}, fn {k, _, _} -> k == member_type end)

    # Plus plan: parents/in-laws attract slightly higher rate
    rate = if plan_key == "last_expense_plus", do: rate * 1.10, else: rate

    total_lives  = members * lives_per_member
    base_premium = round(sum_insured * rate * total_lives)
    min_premium  = 15_000
    premium      = max(base_premium, min_premium)

    ira_levy = round(premium * 0.0025)
    total    = premium + ira_levy

    quote_data = %{
      plan:          plan.name,
      members:       members,
      member_type:   type_label,
      lives_covered: total_lives,
      cover_label:   cover_label,
      sum_insured:   sum_insured,
      rate_pct:      Float.round(rate * 100, 2),
      base_premium:  premium,
      ira_levy:      ira_levy,
      total:         total,
      monthly:       div(total, 12),
      per_member:    div(total, max(members, 1))
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
          plan_name:            "Group Last Expense – #{qd.plan}",
          email:                user.email,
          plan_type:            "last_expense",
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

  def plans,        do: @plans
  def cover_levels, do: @cover_levels
  def member_types, do: @member_types

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

  defp parse_int(nil), do: 10
  defp parse_int(""), do: 10
  defp parse_int(val) do
    case Integer.parse(to_string(val)) do
      {n, _} -> max(n, 1)
      :error  -> 10
    end
  end
end
