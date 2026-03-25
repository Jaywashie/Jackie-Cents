defmodule InsuranceWeb.GroupLifeLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  # Group Life Assurance
  # Kenya market standard: premium = number of members × sum assured multiple × rate
  # Rate bands based on group size and benefit multiple
  # Standard rate: ~0.4% – 0.8% of total sum assured (group life mortality table)

  @benefit_multiples [
    {"1x", "1× Annual Salary", 1},
    {"2x", "2× Annual Salary", 2},
    {"3x", "3× Annual Salary", 3},
    {"4x", "4× Annual Salary", 4},
    {"5x", "5× Annual Salary", 5}
  ]

  @group_sizes [
    {"10_49",   "10 – 49 employees",   0.0070},
    {"50_99",   "50 – 99 employees",   0.0060},
    {"100_249", "100 – 249 employees", 0.0055},
    {"250_499", "250 – 499 employees", 0.0050},
    {"500_plus","500+ employees",       0.0045}
  ]

  @plans %{
    "group_life_basic" => %{
      name: "Group Life Basic",
      icon: "",
      description:
        "A straightforward group life assurance scheme that pays a lump sum death benefit " <>
        "to an employee's nominated beneficiaries upon death (natural or accidental) during " <>
        "the policy term. Minimum group size of 10 members. No individual medicals required " <>
        "for groups below the free cover limit.",
      benefits: [
        "Lump sum death benefit: 1× to 5× annual salary",
        "Natural and accidental death covered",
        "Free cover limit (no medicals): up to KES 5,000,000",
        "Minimum group size: 10 employees",
        "Annual renewable policy",
        "Accelerated terminal illness benefit",
        "Funeral expense benefit: up to KES 100,000"
      ]
    },
    "group_life_plus" => %{
      name: "Group Life Plus",
      icon: "",
      description:
        "An enhanced group life scheme adding permanent total disability (PTD) and critical " <>
        "illness benefits to the base death cover. Includes a last expense benefit and " <>
        "optional group personal accident extension. Ideal for organisations wanting " <>
        "comprehensive welfare for their workforce.",
      benefits: [
        "Death benefit: 1× to 5× annual salary",
        "Permanent total disability: equal to death benefit",
        "Critical illness (10 listed conditions): 50% of sum assured",
        "Last expense / funeral benefit: up to KES 200,000",
        "Accidental death & disability rider (optional)",
        "Education benefit for children on death: up to KES 300,000",
        "Free cover limit: up to KES 10,000,000"
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
    plan_key      = socket.assigns.selected_plan
    plan          = @plans[plan_key]
    employees     = parse_int(params["employees"])
    avg_salary    = parse_int(params["avg_salary"])
    multiple_str  = params["multiple"] || "2x"
    size_key      = params["group_size"] || "10_49"

    {_, _label, multiple} =
      Enum.find(@benefit_multiples, {"2x", "2×", 2}, fn {k, _, _} -> k == multiple_str end)

    {_, _, rate} =
      Enum.find(@group_sizes, {"10_49", "", 0.007}, fn {k, _, _} -> k == size_key end)

    # Plus plan has a small loading for additional benefits
    rate = if plan_key == "group_life_plus", do: rate * 1.20, else: rate

    total_sum_assured = employees * avg_salary * multiple
    base_premium      = round(total_sum_assured * rate)
    min_premium       = 50_000
    premium           = max(base_premium, min_premium)

    ira_levy = round(premium * 0.0025)
    total    = premium + ira_levy

    quote_data = %{
      plan:               plan.name,
      employees:          employees,
      avg_salary:         avg_salary,
      multiple:           multiple,
      total_sum_assured:  total_sum_assured,
      rate_pct:           Float.round(rate * 100, 3),
      base_premium:       premium,
      ira_levy:           ira_levy,
      total:              total,
      monthly:            div(total, 12),
      per_employee:       div(total, max(employees, 1))
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
          plan_name:            "Group Life – #{qd.plan}",
          email:                user.email,
          plan_type:            "group_life",
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

  def plans,          do: @plans
  def benefit_multiples, do: @benefit_multiples
  def group_sizes,    do: @group_sizes

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
