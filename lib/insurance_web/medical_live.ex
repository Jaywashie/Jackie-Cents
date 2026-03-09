defmodule InsuranceWeb.MedicalLive do
  use InsuranceWeb, :live_view

  @milele_rate 12000
  @mwananchi_rate 12000

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       selected_plan: nil,
       quote: nil
     )}
  end

  def handle_event("select_plan", %{"plan" => plan}, socket) do
    {:noreply,
     assign(socket,
       selected_plan: plan,
       quote: nil
     )}
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

    total = base + (dependants * 2000) + (age * 50)

    {:noreply, assign(socket, :quote, total)}
  end

  defp parse_int(nil), do: 0
  defp parse_int(""), do: 0
  defp parse_int(val), do: String.to_integer(val)
end
