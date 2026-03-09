defmodule InsuranceWeb.HomeLive do
  use InsuranceWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  # Example helper function
  def expired?(end_date) do
    Date.compare(end_date, Date.utc_today()) == :lt
  end



def render(assigns) do
  ~H"""
  <div class="min-h-screen bg-gray-50 flex flex-col">

    <!-- HERO -->
    <section class="">
      <div class="max-w-6xl mx-auto px-6 text-center">

        <h2 class="text-5xl font-bold text-gray-900 leading-tight mb-6">
          Secure Your Future with
          <span class="text-green-700">Jackie Cents</span>
        </h2>
      </div>
    </section>

    <!-- PRODUCTS -->
    <section class="max-w-7xl mx-auto px-6 py-16">

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-8">

        <!-- CARD -->
        <div phx-click="go_medical"
          class="group bg-white p-8 rounded-2xl shadow-sm hover:shadow-xl transition cursor-pointer border border-gray-100">
          <div class="w-14 h-14 bg-green-100 text-green-700 flex items-center justify-center rounded-xl mb-6 text-2xl">
            💊
          </div>
          <h3 class="font-semibold text-xl mb-2 group-hover:text-green-700">
            Medical Cover
          </h3>
          <p class="text-gray-600 text-sm">
            Comprehensive health protection for you and your family.
          </p>
        </div>

        <div phx-click="go_life"
          class="group bg-white p-8 rounded-2xl shadow-sm hover:shadow-xl transition cursor-pointer border border-gray-100">
          <div class="w-14 h-14 bg-green-100 text-green-700 flex items-center justify-center rounded-xl mb-6 text-2xl">
            ❤️
          </div>
          <h3 class="font-semibold text-xl mb-2 group-hover:text-green-700">
            Life Insurance
          </h3>
          <p class="text-gray-600 text-sm">
            Long-term financial protection and wealth planning.
          </p>
        </div>

        <div phx-click="go_motor"
          class="group bg-white p-8 rounded-2xl shadow-sm hover:shadow-xl transition cursor-pointer border border-gray-100">
          <div class="w-14 h-14 bg-green-100 text-green-700 flex items-center justify-center rounded-xl mb-6 text-2xl">
            🚗
          </div>
          <h3 class="font-semibold text-xl mb-2 group-hover:text-green-700">
            Motor Cover
          </h3>
          <p class="text-gray-600 text-sm">
            Reliable protection for your vehicle and travel.
          </p>
        </div>

        <div phx-click="go_pension"
          class="group bg-white p-8 rounded-2xl shadow-sm hover:shadow-xl transition cursor-pointer border border-gray-100">
          <div class="w-14 h-14 bg-green-100 text-green-700 flex items-center justify-center rounded-xl mb-6 text-2xl">
            🏦
          </div>
          <h3 class="font-semibold text-xl mb-2 group-hover:text-green-700">
            Pension Plan
          </h3>
          <p class="text-gray-600 text-sm">
            Secure retirement planning and long-term savings.
          </p>
        </div>

      </div>
    </section>

    <!-- TRUST SECTION -->
    <section class="bg-white border-t border-gray-100 py-14">
      <div class="max-w-6xl mx-auto px-6 grid md:grid-cols-3 gap-8 text-center">

        <div>
          <h4 class="text-3xl font-bold text-green-700">10k+</h4>
          <p class="text-gray-600">Active Clients</p>
        </div>

        <div>
          <h4 class="text-3xl font-bold text-green-700">24/7</h4>
          <p class="text-gray-600">Customer Support</p>
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
