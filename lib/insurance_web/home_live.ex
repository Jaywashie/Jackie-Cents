defmodule InsuranceWeb.HomeLive do
  use InsuranceWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  # UI
def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100">


      <!-- HERO -->
      <section class="text-center py-8 bg-white">
        <h2 class="text-3xl font-bold mb-2">
          High-Value Financial Solutions
        </h2>

        <p class="text-gray-600 mb-6">
        Wealth planning,investment strategies and insurance.
        </p>

        <.link
          navigate="/quote"
          class="bg-green-600 text-white px-4 py-2 rounded-lg"
        >
          Get a Quote
        </.link>
      </section>

      <!-- CARDS -->
      <section class="grid grid-cols-1 md:grid-cols-3 gap-6 p-8">

        <div
       phx-click="go_medical"
       class="bg-white shadow rounded-xl p-6 text-center hover:bg-gray-100 cursor-pointer transition">

        <h3 class="font-bold text-xl">Medical Cover</h3>
        <p class="text-gray-600">Health</p>
        </div>

       <div
       phx-click="go_life"
       class="bg-white shadow rounded-xl p-6 text-center hover:bg-gray-100 cursor-pointer transition">

        <h3 class="font-bold text-xl">Life</h3>
        <p class="text-gray-600">Family Protection and savings</p>
        </div>


       <div
       phx-click="go_motor"
       class="bg-white shadow rounded-xl p-6 text-center hover:bg-gray-100 cursor-pointer transition">

        <h3 class="font-bold text-xl">Motor</h3>
        <p class="text-gray-600">Car protection</p>
        </div>

        <div
       phx-click="go_pension"
       class="bg-white shadow rounded-xl p-6 text-center hover:bg-gray-100 cursor-pointer transition">

        <h3 class="font-bold text-xl">Pension</h3>
        <p class="text-gray-600">Retirement Scheme</p>
        </div>

      </section>

    </div>
    """
  end

  # button events
  def handle_event("go_medical", _, socket) do
  {:noreply, push_navigate(socket, to: "/medical")}
end

 def handle_event("go_life", _, socket) do
  {:noreply, push_navigate(socket, to: "/life")}
end


   def handle_event("go_motor", _, socket) do
  {:noreply, push_navigate(socket, to: "/motor")}
end

   def handle_event("go_pension", _, socket) do
  {:noreply, push_navigate(socket, to: "/pension")}
end


end
