defmodule InsuranceWeb.QuoteLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes

  def mount(_params, _session, socket) do
    {:ok, assign(socket, message: nil)}
  end

  def render(assigns) do
    ~H"""
    <div class="p-10">

        <nav class="bg-green-700 text-white p-4 flex justify-between">
        <h1 class="font-bold">JACKIE CENTS</h1>

        <div class="space-x-4">
          <.link navigate="/home">Home</.link>
           <.link navigate="/admin">Admin</.link>

        </div>
      </nav>

      <%= if @message do %>
        <p class="text-green-600"><%= @message %></p>
      <% end %>

      <form phx-submit="save" class="space-y-4">

        <input name="name" placeholder="Name" class="border p-2 w-full"/>
        <input name="email" placeholder="Email" class="border p-2 w-full"/>


        <select name="type" class="border p-2 w-full">
          <option>Medical</option>
          <option>Life</option>
          <option>Motor</option>
          <option>Pension</option>
        </select>

        <div class="flex justify-center">
    <button class="bg-green-600 text-white px-4 py-2">
    Submit
    </button>
    </div>
      </form>

    </div>
    """
  end

  def handle_event("save", params, socket) do
    case Quotes.create_quote(params) do
      {:ok, _quote} ->
        {:noreply, assign(socket, message: "Saved successfully!")}

      {:error, message} ->
        {:noreply, assign(socket, message: message)}
    end
  end
end
