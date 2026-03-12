defmodule InsuranceWeb.AdminLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes
  alias Insurance.Accounts
  alias Insurance.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: InsuranceWeb.Endpoint.subscribe("quotes")

    quotes = Quotes.list_quotes()
    users  = Accounts.list_users()

    {:ok, assign(socket, quotes: quotes, users: users, active_tab: "quotes")}
  end

  @impl true
  def handle_info(%{event: "new_quote", payload: _quote}, socket) do
    {:noreply, assign(socket, quotes: Quotes.list_quotes())}
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, active_tab: tab)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    quote = Quotes.get_quote!(id)
    {:ok, _} = Quotes.delete_quote(quote)
    {:noreply, assign(socket, quotes: Quotes.list_quotes())}
  end

  @impl true
  def handle_event("promote", %{"id" => id}, socket) do
    user = Accounts.get_user!(String.to_integer(id))
    {:ok, _} = Accounts.promote_to_admin(user)
    {:noreply, assign(socket, users: Accounts.list_users())}
  end

  @impl true
  def handle_event("demote", %{"id" => id}, socket) do
    user = Accounts.get_user!(String.to_integer(id))

    # Prevent an admin from demoting themselves
    if user.id == socket.assigns.current_user.id do
      {:noreply, put_flash(socket, :error, "You cannot demote yourself.")}
    else
      {:ok, _} = Accounts.demote_to_user(user)
      {:noreply, assign(socket, users: Accounts.list_users())}
    end
  end

  defp plan_color("pension"), do: "bg-amber-100 text-amber-700"
  defp plan_color("medical"), do: "bg-blue-100 text-blue-700"
  defp plan_color("motor"),   do: "bg-purple-100 text-purple-700"
  defp plan_color("life"),    do: "bg-red-100 text-red-700"
  defp plan_color(_),         do: "bg-gray-100 text-gray-700"

  defp plan_icon("pension"), do: "🏦"
  defp plan_icon("medical"), do: "💊"
  defp plan_icon("motor"),   do: "🚗"
  defp plan_icon("life"),    do: "❤️"
  defp plan_icon(_),         do: "📋"

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">

      <!-- Page Header -->
      <div class="bg-white border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-6 py-6">
          <div class="flex justify-between items-center">
            <div>
              <h1 class="text-2xl font-bold text-gray-900" style="font-family: 'DM Serif Display', serif;">
                Admin Dashboard
              </h1>
              <p class="text-gray-500 text-sm mt-1">Manage quotes and users</p>
            </div>
            <div class="bg-green-100 text-green-700 px-4 py-2 rounded-xl text-sm font-semibold">
              🔴 Live · Logged in as <%= @current_user.email %>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabs -->
      <div class="max-w-7xl mx-auto px-6 pt-6">
        <div class="flex gap-2 mb-6">
          <button
            phx-click="switch_tab" phx-value-tab="quotes"
            class={"px-5 py-2 rounded-xl text-sm font-semibold transition-all " <>
              if @active_tab == "quotes",
                do: "bg-green-600 text-white shadow",
                else: "bg-white text-gray-600 hover:bg-gray-100 border border-gray-200"}
          >
            📋 Quotes (<%= length(@quotes) %>)
          </button>
          <button
            phx-click="switch_tab" phx-value-tab="users"
            class={"px-5 py-2 rounded-xl text-sm font-semibold transition-all " <>
              if @active_tab == "users",
                do: "bg-green-600 text-white shadow",
                else: "bg-white text-gray-600 hover:bg-gray-100 border border-gray-200"}
          >
            👥 Users (<%= length(@users) %>)
          </button>
        </div>
      </div>

      <div class="max-w-7xl mx-auto px-6 pb-10">

        <!-- ── QUOTES TAB ──────────────────────────────────────────── -->
        <%= if @active_tab == "quotes" do %>
          <!-- Stats -->
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
              </div>
            <% end %>
          </div>
        <% end %>

        <!-- ── USERS TAB ───────────────────────────────────────────── -->
        <%= if @active_tab == "users" do %>
          <div class="bg-white shadow-sm rounded-2xl overflow-hidden border border-gray-100">
            <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
              <h2 class="font-semibold text-gray-800">All Users</h2>
              <span class="text-xs text-gray-400">
                <%= Enum.count(@users, &(&1.role == "admin")) %> admin(s) ·
                <%= Enum.count(@users, &(&1.role == "user")) %> regular user(s)
              </span>
            </div>

            <div class="overflow-x-auto">
              <table class="w-full text-sm">
                <thead class="bg-gray-50 text-gray-500 text-xs uppercase tracking-wider">
                  <tr>
                    <th class="px-6 py-4 text-left">Email</th>
                    <th class="px-6 py-4 text-left">Role</th>
                    <th class="px-6 py-4 text-left">Confirmed</th>
                    <th class="px-6 py-4 text-left">Joined</th>
                    <th class="px-6 py-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                  <%= for u <- @users do %>
                    <tr class="hover:bg-gray-50 transition-colors">
                      <td class="px-6 py-4 font-medium text-gray-900">
                        <%= u.email %>
                        <%= if u.id == @current_user.id do %>
                          <span class="ml-2 text-xs text-gray-400">(you)</span>
                        <% end %>
                      </td>
                      <td class="px-6 py-4">
                        <span class={
                          "px-3 py-1 text-xs font-semibold rounded-full " <>
                          if User.admin?(u),
                            do: "bg-green-100 text-green-700",
                            else: "bg-gray-100 text-gray-600"
                        }>
                          <%= if User.admin?(u), do: "👑 Admin", else: "👤 User" %>
                        </span>
                      </td>
                      <td class="px-6 py-4 text-gray-600">
                        <%= if u.confirmed_at, do: "✅ Yes", else: "⏳ Pending" %>
                      </td>
                      <td class="px-6 py-4 text-gray-500">
                        <%= Calendar.strftime(u.inserted_at, "%d %b %Y") %>
                      </td>
                      <td class="px-6 py-4 text-right">
                        <%= if u.id != @current_user.id do %>
                          <%= if User.admin?(u) do %>
                            <button
                              phx-click="demote"
                              phx-value-id={u.id}
                              data-confirm={"Demote #{u.email} to regular user?"}
                              class="text-orange-500 hover:text-orange-700 hover:bg-orange-50 px-3 py-1.5 rounded-lg text-xs font-semibold transition-colors"
                            >
                              Demote to User
                            </button>
                          <% else %>
                            <button
                              phx-click="promote"
                              phx-value-id={u.id}
                              data-confirm={"Promote #{u.email} to admin?"}
                              class="text-green-600 hover:text-green-800 hover:bg-green-50 px-3 py-1.5 rounded-lg text-xs font-semibold transition-colors"
                            >
                              Promote to Admin
                            </button>
                          <% end %>
                        <% else %>
                          <span class="text-gray-300 text-xs">—</span>
                        <% end %>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        <% end %>

      </div>
    </div>
    """
  end
end
