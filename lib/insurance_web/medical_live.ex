defmodule InsuranceWeb.MedicalLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  @milele_rate 12000
  @mwananchi_rate 8000

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       selected_plan: nil,
       quote: nil,
       saving: false,
       saved: false
     )}
  end

  def handle_event("select_plan", %{"plan" => plan}, socket) do
    {:noreply, assign(socket, selected_plan: plan, quote: nil, saved: false)}
  end

  def handle_event("generate_quote", params, socket) do
    age = parse_int(params["age"])
    dependants = parse_int(params["dependants"])

    base =
      case socket.assigns.selected_plan do
        "milele" -> @milele_rate
        "mwananchi" -> @mwananchi_rate
        _ -> 0
      end

    total = base + dependants * 2000 + age * 50
    {:noreply, assign(socket, quote: total, saved: false)}
  end

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
            "milele" -> "Milele Medical Plan"
            "mwananchi" -> "Bima ya Mwananchi"
            _ -> "Medical Plan"
          end

        quote_params = %{
          user_id: user.id,
          plan_name: plan_name,
          email: user.email,
          plan_type: "medical",
          monthly_contribution: div(socket.assigns.quote, 12),
          estimated_value: socket.assigns.quote
        }

        case Quotes.create_quote(quote_params) do
          {:ok, quote} ->
            InsuranceWeb.Endpoint.broadcast("quotes", "new_quote", %{
              id: quote.id,
              plan_name: quote.plan_name,
              plan_type: quote.plan_type,
              email: quote.email,
              monthly_contribution: quote.monthly_contribution,
              estimated_value: quote.estimated_value
            })

            {:noreply, assign(socket, saved: true) |> put_flash(:info, "Quote saved successfully!")}

          {:error, _} ->
            {:noreply, put_flash(socket, :error, "Failed to save quote. Please try again.")}
        end
    end
  end

  defp parse_int(nil), do: 0
  defp parse_int(""), do: 0
  defp parse_int(val), do: String.to_integer(val)
end
