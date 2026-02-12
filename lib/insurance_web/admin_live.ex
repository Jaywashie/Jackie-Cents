defmodule InsuranceWeb.AdminLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes


  def mount(_params, _session, socket) do
    quotes = Quotes.list_quotes()
    {:ok, assign(socket, quotes: quotes)}
  end

  def render(assigns) do
    ~H"""


    <div class="p-10">

          <nav class="bg-green-700 text-white p-4 flex justify-between">
        <h1 class="font-bold">DASHBOARD</h1>

        <div class="space-x-4">
          <.link navigate="/">Home</.link>
          <.link navigate="/quote">Quote</.link>
        </div>
      </nav>


      <table class="table-auto w-full border">
        <thead>
          <tr class="bg-gray-200">
            <th class="p-2">Name</th>
            <th>Email</th>
            <th>Type</th>
            <th>Action</th>
          </tr>
        </thead>

        <tbody>
          <%= for q <- @quotes do %>
            <tr class="border">
              <td class="p-2"><%= q.name %></td>
              <td><%= q.email %></td>
              <td><%= q.type %></td>
              <td>
                <.button
        phx-click="delete"
        phx-value-id={q.id}
        class="bg-green-600 text-white px-3 py-1 rounded"
        data-confirm="Are you sure you want to delete this quote?"
      >
        Delete
      </.button>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>


    </div>
"""
  end

def handle_event("delete", %{"id" => id}, socket) do
  quote = Quotes.get_quote!(id)
  {:ok, _} = Quotes.delete_quote(quote)

  {:noreply, assign(socket, quotes: Quotes.list_quotes())}
end

  end
