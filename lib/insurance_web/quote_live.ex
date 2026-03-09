defmodule InsuranceWeb.QuoteLive do
  use InsuranceWeb, :live_view
  alias Insurance.Quotes


  def mount(_params, _session, socket) do
  if socket.assigns[:current_user] do
    {:ok, assign(socket, message: nil)}
  else
    {:ok,
     socket
     |> put_flash(:error, "You must log in to save a quote")
     |> push_redirect(to: "/users/log_in")}
  end
end

 def render(assigns) do
  ~H"""
  <div class="min-h-screen bg-gray-50 flex flex-col">

    <!-- HERO / HEADER -->
    <section class="bg-white py-16 shadow-sm">
      <div class="max-w-3xl mx-auto px-6 text-center">
        <h2 class="text-4xl font-bold text-gray-900 mb-4">
          Get Your Personalized Quote
        </h2>
        <p class="text-gray-600 mb-8">
          Fill out the form below and we will provide you with the best insurance solutions for your needs.
        </p>
      </div>
    </section>

    <!-- FORM SECTION -->
    <section class="flex-1 flex items-center justify-center py-16">
      <div class="bg-white rounded-3xl shadow-lg max-w-2xl w-full px-10 py-12">

        <%= if @message do %>
          <p class="text-green-600 text-center font-medium mb-6"><%= @message %></p>
        <% end %>

        <form phx-submit="save" class="space-y-6">

          <div>
            <label class="block text-gray-700 font-medium mb-2">Name</label>
            <input name="name" placeholder="Your Full Name" class="border border-gray-300 rounded-lg p-3 w-full focus:ring-2 focus:ring-green-600 focus:outline-none"/>
          </div>

          <div>
            <label class="block text-gray-700 font-medium mb-2">Email</label>
            <input name="email" placeholder="you@example.com" class="border border-gray-300 rounded-lg p-3 w-full focus:ring-2 focus:ring-green-600 focus:outline-none"/>
          </div>

          <div>
            <label class="block text-gray-700 font-medium mb-2">Insurance Type</label>
            <select name="type" class="border border-gray-300 rounded-lg p-3 w-full focus:ring-2 focus:ring-green-600 focus:outline-none">
              <option>Medical</option>
              <option>Life</option>
              <option>Motor</option>
              <option>Pension</option>
            </select>
          </div>

          <div class="flex justify-center">
            <button class="bg-green-600 hover:bg-green-700 text-white font-semibold px-8 py-3 rounded-xl shadow-lg transition">
              Submit
            </button>
          </div>

        </form>
      </div>
    </section>

    <!-- TRUST / INFO SECTION -->
    <section class="bg-green-50 py-12">
      <div class="max-w-5xl mx-auto px-6 grid md:grid-cols-3 gap-8 text-center">

        <div>
          <h4 class="text-3xl font-bold text-green-700">10k+</h4>
          <p class="text-gray-600">Satisfied Clients</p>
        </div>

        <div>
          <h4 class="text-3xl font-bold text-green-700">24/7</h4>
          <p class="text-gray-600">Support Available</p>
        </div>

        <div>
          <h4 class="text-3xl font-bold text-green-700">Secure</h4>
          <p class="text-gray-600">Encrypted & Trusted</p>
        </div>

      </div>
    </section>


  </div>
  """
end


  def handle_event("save", params, socket) do
  user = socket.assigns.current_user

  quote_params =
    params
    |> Map.put("user_id", user.id)

  case Quotes.create_quote(quote_params) do
    {:ok, _quote} ->
      {:noreply, assign(socket, message: "Saved successfully!")}

    {:error, message} ->
      {:noreply, assign(socket, message: message)}
  end
end
end
