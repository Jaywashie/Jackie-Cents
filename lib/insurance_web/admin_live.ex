defmodule InsuranceWeb.AdminLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: InsuranceWeb.Endpoint.subscribe("quotes")
    quotes = Quotes.list_quotes()
    {:ok, assign(socket, quotes: quotes)}
  end

  @impl true
  def handle_info(%{event: "new_quote", payload: quote}, socket) do
    {:noreply, assign(socket, quotes: [quote | socket.assigns.quotes])}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    quote = Quotes.get_quote!(id)
    {:ok, _} = Quotes.delete_quote(quote)
    {:noreply, assign(socket, quotes: Quotes.list_quotes())}
  end

  defp plan_color("pension"), do: "bg-amber-100 text-amber-700"
  defp plan_color("medical"), do: "bg-blue-100 text-blue-700"
  defp plan_color("motor"), do: "bg-purple-100 text-purple-700"
  defp plan_color("life"), do: "bg-red-100 text-red-700"
  defp plan_color(_), do: "bg-gray-100 text-gray-700"

  defp plan_icon("pension"), do: "🏦"
  defp plan_icon("medical"), do: "💊"
  defp plan_icon("motor"), do: "🚗"
  defp plan_icon("life"), do: "❤️"
  defp plan_icon(_), do: "📋"

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">

      <!-- Page Header -->
      <div class="bg-white border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-6 py-6">
          <div class="flex justify-between items-center">
            <div>
              <h1 class="text-2xl font-bold text-gray-900" style="font-family: 'DM Serif Display', serif;">Admin Dashboard</h1>
              <p class="text-gray-500 text-sm mt-1">Manage all insurance quotes in real-time</p>
            </div>
            <div class="flex items-center gap-3">
              <div class="bg-green-100 text-green-700 px-4 py-2 rounded-xl text-sm font-semibold">
                🔴 Live · <%= length(@quotes) %> Quotes
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Stats Cards -->
      <div class="max-w-7xl mx-auto px-6 py-6">
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
          <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
            <div class="text-2xl font-bold text-gray-900"><%= length(@quotes) %></div>
            <div class="text-gray-500 text-sm">Total Quotes</div>
          </div>
          <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
            <div class="text-2xl font-bold text-blue-600"><%= Enum.count(@quotes, &(&1.plan_type == "medical")) %></div>
            <div class="text-gray-500 text-sm">💊 Medical</div>
          </div>
          <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
            <div class="text-2xl font-bold text-amber-600"><%= Enum.count(@quotes, &(&1.plan_type == "pension")) %></div>
            <div class="text-gray-500 text-sm">🏦 Pension</div>
          </div>
          <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
            <div class="text-2xl font-bold text-purple-600"><%= Enum.count(@quotes, &(&1.plan_type == "motor")) %></div>
            <div class="text-gray-500 text-sm">🚗 Motor</div>
          </div>
        </div>

        <!-- Table -->
        <div class="bg-white shadow-sm rounded-2xl overflow-hidden border border-gray-100">
          <div class="px-6 py-4 border-b border-gray-100">
            <h2 class="font-semibold text-gray-800">All Quotes</h2>
          </div>

          <div class="overflow-x-auto">
            <table class="w-full text-sm">
              <thead class="bg-gray-50 text-gray-500 text-xs uppercase tracking-wider">
                <tr>
                  <th class="px-6 py-4 text-left">Plan</th>
                  <th class="px-6 py-4 text-left">Email</th>
                  <th class="px-6 py-4 text-left">Type</th>
                  <th class="px-6 py-4 text-right">Monthly</th>
                  <th class="px-6 py-4 text-right">Est. Value</th>
                  <th class="px-6 py-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-50">
                <%= for q <- @quotes do %>
                  <tr class="hover:bg-gray-50 transition-colors">
                    <td class="px-6 py-4">
                      <div class="flex items-center gap-3">
                        <span class="text-lg"><%= plan_icon(q.plan_type) %></span>
                        <span class="font-medium text-gray-900 text-sm"><%= q.plan_name %></span>
                      </div>
                    </td>
                    <td class="px-6 py-4 text-gray-600"><%= q.email %></td>
                    <td class="px-6 py-4">
                      <span class={"px-3 py-1 text-xs font-semibold rounded-full " <> plan_color(q.plan_type)}>
                        <%= q.plan_type && String.capitalize(q.plan_type) || "Unknown" %>
                      </span>
                    </td>
                    <td class="px-6 py-4 text-right text-gray-700 font-medium">KES <%= q.monthly_contribution %></td>
                    <td class="px-6 py-4 text-right text-gray-900 font-semibold">KES <%= q.estimated_value %></td>
                    <td class="px-6 py-4 text-right">
                      <button
                        phx-click="delete"
                        phx-value-id={q.id}
                        data-confirm="Delete this quote?"
                        class="text-red-500 hover:text-red-700 hover:bg-red-50 px-3 py-1.5 rounded-lg text-xs font-semibold transition-colors"
                      >
                        Delete
                      </button>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>

          <%= if @quotes == [] do %>
            <div class="text-center py-20">
              <div class="text-4xl mb-4">📋</div>
              <p class="text-gray-400 text-lg font-medium">No quotes yet</p>
              <p class="text-gray-300 text-sm mt-1">Quotes will appear here in real-time as users generate them</p>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
