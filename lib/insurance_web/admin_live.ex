defmodule InsuranceWeb.AdminLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  @impl true
  def mount(_params, _session, socket) do

     if connected?(socket), do: InsuranceWeb.Endpoint.subscribe("quotes")
    {:ok, assign(socket, quotes: Quotes.list_quotes())}
  end

  @impl true
def handle_info(%{event: "new_quote", payload: quote}, socket) do
  # Append the new quote to the assigns
  {:noreply, assign(socket, quotes: [quote | socket.assigns.quotes])}
end

# Assign the sorted quotes to the socket
# assign(socket, quotes: Enum.sort([quote | socket.assigns.quotes], &(&1.inserted_at >= &2.inserted_at)))


  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    quote = Quotes.get_quote!(id)
    {:ok, _} = Quotes.delete_quote(quote)

    {:noreply, assign(socket, quotes: Quotes.list_quotes())}
  end

@impl true
def render(assigns) do
  ~H"""
<div class="min-h-screen bg-gray-50">


  <!-- PAGE CONTENT -->
  <div class="max-w-7xl mx-auto px-6 py-12 space-y-8">

    <!-- TABLE CARD -->
    <div class="bg-white shadow-xl rounded-2xl overflow-hidden border border-gray-100">

      <!-- HEADER -->
      <div class="px-8 py-6 border-b border-gray-200 flex justify-between items-center">
        <h2 class="text-xl font-semibold text-gray-800">Admin Dashboard</h2>
        <span class="text-sm text-gray-500"><%= length(@quotes) %> quotes</span>
      </div>

      <!-- QUOTES TABLE -->
      <div class="overflow-x-auto">
        <table class="w-full text-sm text-left border-collapse">
          <thead class="bg-gray-100 text-gray-600 uppercase text-xs tracking-wider">
            <tr>

              <th class="px-8 py-4">Email</th>
              <th class="px-8 py-4">Contribution</th>
              <th class="px-8 py-4">Estimated Value</th>
              <th class="px-8 py-4">Type</th>
              <th class="px-8 py-4 text-right">Actions</th>
            </tr>
          </thead>

          <tbody class="divide-y divide-gray-100">
            <%= for q <- @quotes do %>
              <tr class="hover:bg-gray-50 transition">

                <td class="px-8 py-5 text-gray-600"><%= q.email %></td>
                <td class="px-8 py-5 text-gray-600">KES <%= q.monthly_contribution %></td>
                <td class="px-8 py-5 text-gray-600">KES <%= q.estimated_value %></td>
                <td class="px-8 py-5">
                  <span class={"px-4 py-2 text-sm font-semibold rounded-full " <>
                                if q.plan_type == "pension", do: "bg-green-100 text-green-700", else: "bg-blue-100 text-blue-700"}>
                    <%= q.plan_type && String.capitalize(q.plan_type) || "Unknown" %>
                  </span>
                </td>
                <td class="px-8 py-5 text-right">
                  <.button
                    phx-click="delete"
                    phx-value-id={q.id}
                    data-confirm="Delete this quote?"
                    class="bg-red-500 hover:bg-red-600 text-white px-5 py-2 rounded-lg shadow-sm transition font-medium"
                  >
                    Delete
                  </.button>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>

      <!-- EMPTY STATE -->
      <%= if @quotes == [] do %>
        <div class="text-center py-20">
          <p class="text-gray-400 text-lg">No quotes yet</p>
        </div>
      <% end %>

    </div>
  </div>
</div>
"""
end
end
