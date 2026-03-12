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
            <div class="text-3xl font-bold text-green-700 mb-1">4</div>
            <div class="text-gray-500 text-sm">Insurance Types</div>
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
            Our Insurance Products
          </h2>
          <p class="text-gray-500 max-w-xl mx-auto">
            Choose from our range of comprehensive insurance solutions designed to protect every aspect of your life.
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">

          <!-- Medical -->
          <div phx-click="go_medical" class="group bg-white p-8 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 cursor-pointer border border-gray-100 hover:border-green-200 card-hover">
            <div class="flex items-start gap-5">

              <div class="flex-1">
                <h3 class="font-bold text-xl text-gray-900 mb-2 group-hover:text-green-700 transition-colors">
                  Medical Cover
                </h3>
                <p class="text-gray-500 text-sm leading-relaxed mb-4">
                  Comprehensive health protection for you and your family. Inpatient, outpatient, maternity and dental benefits.
                </p>
                <div class="flex items-center text-green-600 text-sm font-semibold group-hover:gap-2 transition-all">
                  Get Quote <span class="ml-1">→</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Life -->
          <div phx-click="go_life" class="group bg-white p-8 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 cursor-pointer border border-gray-100 hover:border-green-200 card-hover">
            <div class="flex items-start gap-5">

              <div class="flex-1">
                <h3 class="font-bold text-xl text-gray-900 mb-2 group-hover:text-green-700 transition-colors">
                  Life Insurance
                </h3>
                <p class="text-gray-500 text-sm leading-relaxed mb-4">
                  Long-term financial protection and wealth planning. Whole life, term life, education and savings plans.
                </p>
                <div class="flex items-center text-green-600 text-sm font-semibold">
                  Get Quote <span class="ml-1">→</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Motor -->
          <div phx-click="go_motor" class="group bg-white p-8 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 cursor-pointer border border-gray-100 hover:border-green-200 card-hover">
            <div class="flex items-start gap-5">

              <div class="flex-1">
                <h3 class="font-bold text-xl text-gray-900 mb-2 group-hover:text-green-700 transition-colors">
                  Motor Cover
                </h3>
                <p class="text-gray-500 text-sm leading-relaxed mb-4">
                  Reliable protection for your vehicle. Comprehensive and third party options for every budget.
                </p>
                <div class="flex items-center text-green-600 text-sm font-semibold">
                  Get Quote <span class="ml-1">→</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Pension -->
          <div phx-click="go_pension" class="group bg-white p-8 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 cursor-pointer border border-gray-100 hover:border-green-200 card-hover">
            <div class="flex items-start gap-5">

              <div class="flex-1">
                <h3 class="font-bold text-xl text-gray-900 mb-2 group-hover:text-green-700 transition-colors">
                  Pension Plan
                </h3>
                <p class="text-gray-500 text-sm leading-relaxed mb-4">
                  Secure retirement planning and long-term savings. Build a guaranteed income for your golden years.
                </p>
                <div class="flex items-center text-green-600 text-sm font-semibold">
                  Get Quote <span class="ml-1">→</span>
                </div>
              </div>
            </div>
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
end
