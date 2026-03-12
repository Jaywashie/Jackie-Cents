defmodule InsuranceWeb.LifeLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  @plans %{
    "akiba" => %{
      name: "Britam Akiba Life Savings Plan",
      base: 10000,
      icon: "",
      min_term: 5,
      max_term: 12,
      min_age: 18,
      max_age: 65
    },
    "education" => %{
      name: "Britam Boresha Elimu Education Plan",
      base: 12000,
      icon: "",
      min_term: 6,
      max_term: 18,
      min_age: 18,
      max_age: 60
    },
    "whole_life" => %{
      name: "Britam Whole Life Plan",
      base: 15000,
      icon: "",
      min_term: nil,
      max_term: nil,
      min_age: 18,
      max_age: 65
    },
    "term_life" => %{
      name: "Britam Term Life Plan",
      base: 8000,
      icon: "",
      min_term: 10,
      max_term: 20,
      min_age: 18,
      max_age: 65
    }
  }

  def mount(_, _, socket) do
    {:ok, assign(socket, selected_plan: nil, quote: nil, plans: @plans, saved: false)}
  end

  def handle_event("select_plan", %{"plan" => plan}, socket) do
    {:noreply, assign(socket, selected_plan: plan, quote: nil, saved: false)}
  end

  def handle_event("generate_quote", params, socket) do
    age        = parse_int(params["age"])
    cover      = parse_int(params["sum_assured"])
    term       = parse_int(params["policy_term"])
    plan_key   = socket.assigns.selected_plan
    base       = socket.assigns.plans[plan_key].base

    # Premium formula: base rate + age loading + cover loading + term discount
    age_loading    = age * 120
    cover_loading  = div(cover, 1000) * 2
    term_discount  = if term >= 10, do: -500, else: 0
    annual_premium = base + age_loading + cover_loading + term_discount

    {:noreply, assign(socket, quote: annual_premium, saved: false)}
  end

  def handle_event("save_quote", _params, socket) do
    case socket.assigns.current_user do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Please log in to save a quote")
         |> push_navigate(to: "/users/log_in")}

      user ->
        plan = socket.assigns.plans[socket.assigns.selected_plan]

        quote_params = %{
          user_id:              user.id,
          plan_name:            plan.name,
          email:                user.email,
          plan_type:            "life",
          monthly_contribution: div(socket.assigns.quote, 12),
          estimated_value:      socket.assigns.quote
        }

        case Quotes.create_quote(quote_params) do
          {:ok, quote} ->
            InsuranceWeb.Endpoint.broadcast("quotes", "new_quote", %{
              id:                   quote.id,
              plan_name:            quote.plan_name,
              plan_type:            quote.plan_type,
              email:                quote.email,
              monthly_contribution: quote.monthly_contribution,
              estimated_value:      quote.estimated_value
            })

            {:noreply, assign(socket, saved: true) |> put_flash(:info, "Quote saved successfully!")}

          {:error, _} ->
            {:noreply, put_flash(socket, :error, "Failed to save quote. Please try again.")}
        end
    end
  end

  defp parse_int(nil), do: 0
  defp parse_int(""), do: 0

  defp parse_int(val) do
    case Integer.parse(val) do
      {n, _} -> n
      :error  -> 0
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
end
