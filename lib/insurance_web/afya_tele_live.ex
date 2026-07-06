defmodule InsuranceWeb.AfyaTeleLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  # Afya Tele — Telemedicine + Outpatient Health Plans
  # Designed for individuals and families who want affordable outpatient access
  # bundled with 24/7 telemedicine consultations

  @plans %{
    "tele_basic" => %{
      name: "Afya Tele Basic",
      icon: "",
      annual_individual: 4_800,
      annual_family_2:   7_500,
      annual_family_4:   10_500,
      description:
        "Affordable outpatient cover for individuals. " <>
        "Includes unlimited 24/7 virtual consultations with licensed doctors via app or phone, " <>
        "a fixed outpatient limit for physical visits, and basic lab tests. " <>
        "No waiting period for telemedicine services.",
      benefits: [
        "Unlimited 24/7 telemedicine consultations (app/phone/video)",
        "Outpatient limit: KES 30,000/year per person",
        "Prescription drugs: up to KES 10,000/year",
        "Basic diagnostics & lab tests: up to KES 8,000/year",
        "Mental health & wellness teleconsultations",
        "Specialist referral letters",
        "No waiting period for tele-consult services"
      ]
    },
    "tele_plus" => %{
      name: "Afya Tele Plus",
      icon: "",
      annual_individual: 9_600,
      annual_family_2:   15_000,
      annual_family_4:   22_000,
      description:
        "Comprehensive outpatient and telemedicine plan with higher limits and inpatient " <>
        "emergency top-up. Includes chronic disease management, wellness programs, " <>
        "and optical and dental cover. Ideal for families and professionals.",
      benefits: [
        "Unlimited 24/7 telemedicine (video, voice, chat)",
        "Outpatient limit: KES 80,000/year per person",
        "Prescription drugs: up to KES 25,000/year",
        "Diagnostics, imaging & lab: up to KES 30,000/year",
        "Dental & optical: up to KES 15,000 combined",
        "Chronic disease management programme",
        "Emergency inpatient top-up: KES 150,000",
        "Mental health: up to 12 sessions/year",
        "Annual wellness check-up included"
      ]
    },
    "tele_corporate" => %{
      name: "Afya Tele Corporate",
      icon: "",
      annual_individual: 0,
      annual_family_2:   0,
      annual_family_4:   0,
      per_employee:      7_200,
      description:
        "A group telemedicine and outpatient health plan for organisations with 5+ employees. " <>
        "Reduces absenteeism through instant access to doctors, wellness monitoring, and " <>
        "chronic disease management. Pricing per employee per year.",
      benefits: [
        "Unlimited telemedicine for all enrolled employees",
        "Outpatient limit: KES 60,000/employee/year",
        "Group wellness dashboard for HR",
        "Prescription & lab cover: KES 20,000/employee/year",
        "Dental & optical: KES 12,000/employee/year",
        "Mental health support: up to 10 sessions/employee/year",
        "Minimum group size: 5 employees",
        "Annual health reports per employee",
        "Dedicated account manager"
      ]
    }
  }

  @member_types [
    {"individual", "Individual"},
    {"family_2", "Family (Principal + Spouse)"},
    {"family_4", "Family (Principal + Spouse + up to 2 Children)"}
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
    plan_key    = socket.assigns.selected_plan
    plan        = @plans[plan_key]
    member_type = params["member_type"] || "individual"
    employees   = parse_int(params["employees"])

    annual_premium =
      cond do
        plan_key == "tele_corporate" ->
          plan.per_employee * max(employees, 5)

        member_type == "family_4" ->
          plan.annual_family_4

        member_type == "family_2" ->
          plan.annual_family_2

        true ->
          plan.annual_individual
      end

    ira_levy = round(annual_premium * 0.0025)
    total    = annual_premium + ira_levy

    quote_data = %{
      plan:          plan.name,
      member_type:   member_type,
      employees:     employees,
      corporate?:    plan_key == "tele_corporate",
      base_premium:  annual_premium,
      ira_levy:      ira_levy,
      total:         total,
      monthly:       div(total, 12)
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
          plan_name:            "Afya Tele – #{qd.plan}",
          email:                user.email,
          plan_type:            "afya_tele",
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

  defp parse_int(nil), do: 5
  defp parse_int(""), do: 5
  defp parse_int(val) do
    case Integer.parse(to_string(val)) do
      {n, _} -> max(n, 1)
      :error  -> 5
    end
  end
end
