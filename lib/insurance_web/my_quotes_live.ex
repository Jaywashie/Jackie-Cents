defmodule InsuranceWeb.MyQuotesLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    quotes = Quotes.list_quotes_for_user(user.id)

    {:ok,
     socket
     |> assign(:quotes, quotes)
     |> assign(:filter, "all")}
  end

  @impl true
  def handle_event("filter", %{"type" => type}, socket) do
    user = socket.assigns.current_user
    quotes =
      case type do
        "all" -> Quotes.list_quotes_for_user(user.id)
        plan_type -> Quotes.list_quotes_for_user_by_type(user.id, plan_type)
      end

    {:noreply, assign(socket, quotes: quotes, filter: type)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    quote = Quotes.get_quote!(id)

    # Security check — ensure quote belongs to current user
    if quote.user_id == socket.assigns.current_user.id do
      {:ok, _} = Quotes.delete_quote(quote)
    end

    quotes = Quotes.list_quotes_for_user(socket.assigns.current_user.id)
    {:noreply, assign(socket, quotes: quotes)}
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

  defp plan_link("medical"), do: "/medical"
  defp plan_link("life"), do: "/life"
  defp plan_link("motor"), do: "/motor"
  defp plan_link("pension"), do: "/pension"
  defp plan_link(_), do: "/"

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">

      <!-- Header -->
      <div class="bg-white border-b border-gray-200">
        <div class="max-w-5xl mx-auto px-6 py-8">
          <h1 class="text-2xl font-bold text-gray-900" style="font-family: 'DM Serif Display', serif;">
            My Quotes
          </h1>
          <p class="text-gray-500 text-sm mt-1">All your saved insurance quotes in one place</p>
        </div>
      </div>

      <div class="max-w-5xl mx-auto px-6 py-8">

        <!-- Summary Cards -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
          <div class="bg-white rounded-xl p-4 shadow-sm border border-gray-100 text-center">
            <div class="text-2xl font-bold text-gray-900"><%= length(@quotes) %></div>
            <div class="text-gray-500 text-xs mt-1">Total Quotes</div>
          </div>
          <div class="bg-white rounded-xl p-4 shadow-sm border border-blue-100 text-center">
            <div class="text-2xl font-bold text-blue-600">
              <%= Enum.count(@quotes, &(&1.plan_type == "medical")) %>
            </div>
            <div class="text-gray-500 text-xs mt-1">💊 Medical</div>
          </div>
          <div class="bg-white rounded-xl p-4 shadow-sm border border-red-100 text-center">
            <div class="text-2xl font-bold text-red-500">
              <%= Enum.count(@quotes, &(&1.plan_type == "life")) %>
            </div>
            <div class="text-gray-500 text-xs mt-1">❤️ Life</div>
          </div>
          <div class="bg-white rounded-xl p-4 shadow-sm border border-purple-100 text-center">
            <div class="text-2xl font-bold text-purple-600">
              <%= Enum.count(@quotes, &(&1.plan_type == "motor")) %>
            </div>
            <div class="text-gray-500 text-xs mt-1">🚗 Motor</div>
          </div>
        </div>

        <!-- Filter Tabs -->
        <div class="flex gap-2 mb-6 flex-wrap">
          <%= for {label, value} <- [{"All", "all"}, {"💊 Medical", "medical"}, {"❤️ Life", "life"}, {"🚗 Motor", "motor"}, {"🏦 Pension", "pension"}] do %>
            <button
              phx-click="filter"
              phx-value-type={value}
              class={"px-4 py-2 rounded-xl text-sm font-semibold transition-all " <>
                if @filter == value,
                  do: "bg-green-600 text-white shadow",
                  else: "bg-white text-gray-600 hover:bg-gray-100 border border-gray-200"}
            >
              <%= label %>
            </button>
          <% end %>
        </div>

        <!-- Quotes List -->
        <%= if @quotes == [] do %>
          <div class="bg-white rounded-2xl p-16 text-center border border-gray-100 shadow-sm">
            <div class="text-5xl mb-4">📋</div>
            <p class="text-gray-500 font-medium text-lg">No quotes yet</p>
            <p class="text-gray-400 text-sm mt-2 mb-6">Generate a quote from any insurance product page</p>
            <div class="flex gap-3 justify-center flex-wrap">
              <.link navigate="/medical" class="bg-green-600 text-white px-5 py-2 rounded-xl text-sm font-semibold hover:bg-green-700 transition-all">
                💊 Medical Quote
              </.link>
              <.link navigate="/life" class="bg-green-600 text-white px-5 py-2 rounded-xl text-sm font-semibold hover:bg-green-700 transition-all">
                ❤️ Life Quote
              </.link>
              <.link navigate="/motor" class="bg-green-600 text-white px-5 py-2 rounded-xl text-sm font-semibold hover:bg-green-700 transition-all">
                🚗 Motor Quote
              </.link>
              <.link navigate="/pension" class="bg-green-600 text-white px-5 py-2 rounded-xl text-sm font-semibold hover:bg-green-700 transition-all">
                🏦 Pension Quote
              </.link>
            </div>
          </div>
        <% else %>
          <div class="space-y-4">
            <%= for q <- @quotes do %>
              <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 flex flex-col md:flex-row md:items-center justify-between gap-4">

                <!-- Left: Plan info -->
                <div class="flex items-center gap-4">
                  <div class="text-3xl"><%= plan_icon(q.plan_type) %></div>
                  <div>
                    <div class="font-semibold text-gray-900"><%= q.plan_name %></div>
                    <span class={"text-xs font-semibold px-2 py-0.5 rounded-full " <> plan_color(q.plan_type)}>
                      <%= q.plan_type && String.capitalize(q.plan_type) %>
                    </span>
                  </div>
                </div>

                <!-- Middle: Financial details -->
                <div class="flex gap-6 text-sm">
                  <div>
                    <div class="text-gray-400 text-xs">Monthly</div>
                    <div class="font-semibold text-gray-800">KES <%= q.monthly_contribution %></div>
                  </div>
                  <div>
                    <div class="text-gray-400 text-xs">Est. Value</div>
                    <div class="font-bold text-gray-900">KES <%= q.estimated_value %></div>
                  </div>
                  <div>
                    <div class="text-gray-400 text-xs">Saved on</div>
                    <div class="text-gray-600"><%= Calendar.strftime(q.inserted_at, "%d %b %Y") %></div>
                  </div>
                </div>

                <!-- Right: Actions -->
                <div class="flex gap-2 items-center">
                  <.link
                    navigate={plan_link(q.plan_type)}
                    class="text-green-600 hover:bg-green-50 border border-green-200 px-4 py-2 rounded-xl text-xs font-semibold transition-all"
                  >
                    Get New Quote
                  </.link>
                  <button
                    phx-click="delete"
                    phx-value-id={q.id}
                    data-confirm="Remove this quote?"
                    class="text-red-500 hover:bg-red-50 border border-red-200 px-4 py-2 rounded-xl text-xs font-semibold transition-all"
                  >
                    Remove
                  </button>
                </div>

              </div>
            <% end %>
          </div>
        <% end %>

      </div>
    </div>
    """
  end
end
