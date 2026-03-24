defmodule InsuranceWeb.HomeLive do
  use InsuranceWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">

      <!-- HERO SECTION -->
      <section class="relative overflow-hidden" style="background: linear-gradient(135deg, #14532d 0%, #166534 50%, #15803d 100%);">
        <!-- Background decoration -->
        <div class="absolute inset-0 overflow-hidden">
          <div class="absolute -top-24 -right-24 w-96 h-96 bg-white/5 rounded-full"></div>
          <div class="absolute top-1/2 -left-16 w-64 h-64 bg-white/5 rounded-full"></div>
          <div class="absolute bottom-0 right-1/3 w-48 h-48 bg-white/5 rounded-full"></div>
        </div>

        <div class="relative max-w-7xl mx-auto px-6 py-24 lg:py-32">
          <div class="max-w-3xl">
            <div class="inline-flex items-center bg-white/10 text-green-200 px-4 py-2 rounded-full text-sm font-medium mb-6 border border-white/20">
              🇰🇪 Kenya's Trusted Insurance Partner
            </div>
            <h1 class="text-5xl lg:text-6xl font-bold text-white leading-tight mb-6" style="font-family: 'DM Serif Display', serif;">
              Secure Your Future,
              <span class="text-green-300">Protect What Matters</span>
            </h1>
            <p class="text-xl text-green-100 mb-10 leading-relaxed max-w-2xl">
              Comprehensive insurance solutions tailored for Kenyans. Medical, life, motor, and pension plans designed to give you peace of mind every day.
            </p>
            <div class="flex flex-wrap gap-4">
              <.link navigate="/medical" class="btn-primary text-white px-8 py-4 rounded-xl font-semibold text-base shadow-lg inline-flex items-center gap-2">
                Get a Quote <span>→</span>
              </.link>
              <%= if !@current_user do %>
                <.link navigate="/users/register" class="bg-white/10 hover:bg-white/20 text-white border border-white/30 px-8 py-4 rounded-xl font-semibold text-base transition-all inline-flex items-center gap-2">
                  Create Account
                </.link>
              <% end %>
            </div>
          </div>
        </div>

        <!-- Wave divider -->
        <div class="absolute bottom-0 left-0 right-0">
          <svg viewBox="0 0 1440 60" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M0 60L1440 60L1440 0C1440 0 1080 60 720 60C360 60 0 0 0 0L0 60Z" fill="#f9fafb"/>
          </svg>
        </div>
      </section>

      <!-- STATS SECTION -->
      <section class="max-w-7xl mx-auto px-6 -mt-4 mb-16">
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
          <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 text-center card-hover">
            <div class="text-3xl font-bold text-green-700 mb-1">10k+</div>
            <div class="text-gray-500 text-sm">Active Clients</div>
          </div>
          <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 text-center card-hover">
            <div class="text-3xl font-bold text-green-700 mb-1">24/7</div>
            <div class="text-gray-500 text-sm">Support</div>
          </div>
          <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 text-center card-hover">
            <div class="text-3xl font-bold text-green-700 mb-1">8</div>
            <div class="text-gray-500 text-sm">Product Types</div>
          </div>
          <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 text-center card-hover">
            <div class="text-3xl font-bold text-green-700 mb-1">98%</div>
            <div class="text-gray-500 text-sm">Claim Success</div>
          </div>
        </div>
      </section>

      <!-- PRODUCTS SECTION -->
      <section class="max-w-7xl mx-auto px-6 pb-20">
        <div class="text-center mb-12">
          <h2 class="text-3xl font-bold text-gray-900 mb-3" style="font-family: 'DM Serif Display', serif;">
            Our Products & Services
          </h2>
          <p class="text-gray-500 max-w-xl mx-auto">
            Choose from our range of comprehensive solutions designed to protect your life and grow your wealth.
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">

          <!-- Medical -->
          <div phx-click="go_medical" class="group bg-white p-6 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 cursor-pointer border border-gray-100 hover:border-green-200 card-hover">
            <div class="w-12 h-12 bg-blue-50 text-blue-600 rounded-xl flex items-center justify-center mb-4 text-xl">🏥</div>
            <h3 class="font-bold text-lg text-gray-900 mb-2 group-hover:text-green-700">Medical Cover</h3>
            <p class="text-gray-500 text-xs leading-relaxed mb-4">Health protection for you and your family.</p>
            <div class="text-green-600 text-xs font-semibold">Get Quote →</div>
          </div>

          <!-- Life -->
          <div phx-click="go_life" class="group bg-white p-6 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 cursor-pointer border border-gray-100 hover:border-green-200 card-hover">
            <div class="w-12 h-12 bg-red-50 text-red-600 rounded-xl flex items-center justify-center mb-4 text-xl">❤️</div>
            <h3 class="font-bold text-lg text-gray-900 mb-2 group-hover:text-green-700">Life Insurance</h3>
            <p class="text-gray-500 text-xs leading-relaxed mb-4">Long-term financial protection for loved ones.</p>
            <div class="text-green-600 text-xs font-semibold">Get Quote →</div>
          </div>

          <!-- Motor -->
          <div phx-click="go_motor" class="group bg-white p-6 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 cursor-pointer border border-gray-100 hover:border-green-200 card-hover">
            <div class="w-12 h-12 bg-purple-50 text-purple-600 rounded-xl flex items-center justify-center mb-4 text-xl">🚗</div>
            <h3 class="font-bold text-lg text-gray-900 mb-2 group-hover:text-green-700">Motor Cover</h3>
            <p class="text-gray-500 text-xs leading-relaxed mb-4">Reliable protection for your vehicle.</p>
            <div class="text-green-600 text-xs font-semibold">Get Quote →</div>
          </div>

          <!-- Pension -->
          <div phx-click="go_pension" class="group bg-white p-6 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 cursor-pointer border border-gray-100 hover:border-green-200 card-hover">
            <div class="w-12 h-12 bg-amber-50 text-amber-600 rounded-xl flex items-center justify-center mb-4 text-xl">🏦</div>
            <h3 class="font-bold text-lg text-gray-900 mb-2 group-hover:text-green-700">Pension Plan</h3>
            <p class="text-gray-500 text-xs leading-relaxed mb-4">Secure retirement planning and savings.</p>
            <div class="text-green-600 text-xs font-semibold">Get Quote →</div>
          </div>

          <!-- Money Market -->
          <div phx-click="go_mmf" class="group bg-white p-6 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 cursor-pointer border border-gray-100 hover:border-green-200 card-hover">
            <div class="w-12 h-12 bg-cyan-50 text-cyan-600 rounded-xl flex items-center justify-center mb-4 text-xl">💰</div>
            <h3 class="font-bold text-lg text-gray-900 mb-2 group-hover:text-green-700">Money Market</h3>
            <p class="text-gray-500 text-xs leading-relaxed mb-4">High-yield savings with instant liquidity.</p>
            <div class="text-green-600 text-xs font-semibold">Calculate →</div>
          </div>

          <!-- Unit Trust -->
          <div phx-click="go_ut" class="group bg-white p-6 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 cursor-pointer border border-gray-100 hover:border-green-200 card-hover">
            <div class="w-12 h-12 bg-emerald-50 text-emerald-600 rounded-xl flex items-center justify-center mb-4 text-xl">📈</div>
            <h3 class="font-bold text-lg text-gray-900 mb-2 group-hover:text-green-700">Unit Trusts</h3>
            <p class="text-gray-500 text-xs leading-relaxed mb-4">Professional wealth management & growth.</p>
            <div class="text-green-600 text-xs font-semibold">Invest Now →</div>
          </div>

          <!-- SME -->
          <div phx-click="go_sme" class="group bg-white p-6 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 cursor-pointer border border-gray-100 hover:border-green-200 card-hover">
            <div class="w-12 h-12 bg-indigo-50 text-indigo-600 rounded-xl flex items-center justify-center mb-4 text-xl">🏬</div>
            <h3 class="font-bold text-lg text-gray-900 mb-2 group-hover:text-green-700">SME Insurance</h3>
            <p class="text-gray-500 text-xs leading-relaxed mb-4">Tailored protection for your business.</p>
            <div class="text-green-600 text-xs font-semibold">Get Quote →</div>
          </div>

          <!-- WIBA -->
          <div phx-click="go_wiba" class="group bg-white p-6 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 cursor-pointer border border-gray-100 hover:border-green-200 card-hover">
            <div class="w-12 h-12 bg-orange-50 text-orange-600 rounded-xl flex items-center justify-center mb-4 text-xl">👷</div>
            <h3 class="font-bold text-lg text-gray-900 mb-2 group-hover:text-green-700">WIBA Cover</h3>
            <p class="text-gray-500 text-xs leading-relaxed mb-4">Work Injury Benefits for your employees.</p>
            <div class="text-green-600 text-xs font-semibold">Get Quote →</div>
          </div>

        </div>
      </section>

      <!-- WHY CHOOSE US -->
      <section class="bg-white border-t border-gray-100 py-20">
        <div class="max-w-7xl mx-auto px-6">
          <div class="text-center mb-12">
            <h2 class="text-3xl font-bold text-gray-900" style="font-family: 'DM Serif Display', serif;">
              Why Choose JackieCents?
            </h2>
          </div>
          <div class="grid md:grid-cols-3 gap-8">
            <div class="text-center">
              <div class="w-16 h-16 bg-green-100 rounded-2xl flex items-center justify-center mx-auto mb-4 text-2xl">🔒</div>
              <h3 class="font-bold text-gray-900 mb-2">Secure & Trusted</h3>
              <p class="text-gray-500 text-sm">Your data and policies are protected with bank-grade security.</p>
            </div>
            <div class="text-center">
              <div class="w-16 h-16 bg-green-100 rounded-2xl flex items-center justify-center mx-auto mb-4 text-2xl">⚡</div>
              <h3 class="font-bold text-gray-900 mb-2">Instant Quotes</h3>
              <p class="text-gray-500 text-sm">Get personalized insurance quotes in seconds, not days.</p>
            </div>
            <div class="text-center">
              <div class="w-16 h-16 bg-green-100 rounded-2xl flex items-center justify-center mx-auto mb-4 text-2xl">🤝</div>
              <h3 class="font-bold text-gray-900 mb-2">Dedicated Support</h3>
              <p class="text-gray-500 text-sm">Our team is available 24/7 to help you with any questions.</p>
            </div>
          </div>
        </div>
      </section>

      <!-- CTA SECTION -->
      <%= if !@current_user do %>
        <section class="py-20 px-6" style="background: linear-gradient(135deg, #14532d, #15803d);">
          <div class="max-w-3xl mx-auto text-center">
            <h2 class="text-3xl font-bold text-white mb-4" style="font-family: 'DM Serif Display', serif;">
              Ready to get protected?
            </h2>
            <p class="text-green-200 mb-8">Join thousands of Kenyans who trust JackieCents with their future.</p>
            <.link navigate="/users/register" class="bg-white text-green-700 px-8 py-4 rounded-xl font-bold text-base hover:bg-green-50 transition-all shadow-lg inline-block">
              Start for Free →
            </.link>
          </div>
        </section>
      <% end %>

    </div>
    """
  end

  def handle_event("go_medical", _, socket), do: {:noreply, push_navigate(socket, to: "/medical")}
  def handle_event("go_life", _, socket), do: {:noreply, push_navigate(socket, to: "/life")}
  def handle_event("go_motor", _, socket), do: {:noreply, push_navigate(socket, to: "/motor")}
  def handle_event("go_pension", _, socket), do: {:noreply, push_navigate(socket, to: "/pension")}
  def handle_event("go_mmf", _, socket), do: {:noreply, push_navigate(socket, to: "/money-market")}
  def handle_event("go_ut", _, socket), do: {:noreply, push_navigate(socket, to: "/unit-trust")}
  def handle_event("go_sme", _, socket), do: {:noreply, push_navigate(socket, to: "/sme-insurance")}
  def handle_event("go_wiba", _, socket), do: {:noreply, push_navigate(socket, to: "/wiba")}
end
