defmodule DemoWeb.CounterLive.Index do
    use Phoenix.LiveView
    alias DemoWeb.Router.Helpers, as: Routes

    @phones([
        %{ name: "iPhone", count: 0},
        %{ name: "One Plus", count: 0},
        %{ name: "Huwawei", count: 0},
        %{ name: "Oppo Reno", count: 0},
        %{ name: "RedMi+", count: 0},
        %{ name: "Pixel 5", count: 0},
        %{ name: "Samsung galaxy", count: 0},
        %{ name: "Motorolla", count: 0},
        %{ name: "HTC", count: 0},
        ])
    
    @items([])

    def render(assigns) do
    ~L"""
        <div class="close-cart" phx-click="close-cart">
      <div class="header">
        <p class="cart" phx-click="open-cart">Cart</p>
        <h1>Phoenix Demo Cart</h1>
      </div>
      <div class="product-container">
      <div class="cart-modal-container">
      <%= if @isCartOpen do %>
          <div class="cart-modal">
            <%= if Enum.count(@items) === 0 do %>
              <div class="item-card">
                <p class="remove"> Item 1</p>
                <div>
                  <div class="item-button">
                    <%= 0 %>
                    <button phx-click="dec" class="button-style">-</button>
                    <button phx-click="inc" class="button-style">+</button>
                  </div>
                </div>
              </div>
              <div class="item-card">
                <p class="remove"> Item 2</p>
                <div>
                  <div class="item-button">
                    <%= 0 %>
                    <button phx-click="dec" class="button-style">-</button>
                    <button phx-click="inc" class="button-style">+</button>
                  </div>
                </div>
              </div>
              <div class="item-card">
                <p class="remove"> Item 3</p>
                <div>
                  <div class="item-button">
                    <%= 0 %>
                    <button phx-click="dec" class="button-style">-</button>
                    <button phx-click="inc" class="button-style">+</button>
                  </div>
                </div>
              </div>
            <% else %>
              <%= for item <- @items do %>
                <p>Working now<%= item %></p>
              <% end %>
            <% end %>
          </div>
        <% end %>
    </div>
    <a phx-click="redirect" phx-value-page="<%= "Look for me" %>">Show</a>
        <h1 class="product-header">Products</h1>
      <div class="cardcontainer">
        <%= for phone <- @phones do %>
          <div class="card">
          <p class="card-heading"><%= phone.name %></p>
          <img src="https://ekameco.com/wp-content/uploads/2019/03/product-placeholder-300x300.jpg" class="image"/>
          <div class="button-group">
            <button phx-click="dec" phx-value="<%= phone.name %>" class="button-style">-</button>
            <button phx-click="inc" phx-value="<%= phone.name %>" class="button-style">+</button>
          </div>
          </div>
        <% end %>
      </div>
      </div>
      </div>
    """
    #   DemoWeb.CounterView.render("index.html", assigns)
    #   DemoWeb.NewView.render("index.html", assigns)
    end

    def mount(_params, _session, socket) do
      {:ok, assign(
          socket,
          val: 0,
          phones: @phones,
          isCartOpen: false,
          items: @items
        )}
    end

    def handle_event("close-cart", _, socket) do
      {:noreply, update(socket, :isCartOpen, &(&1 = false))}
    end

    def handle_event("redirect", %{"page" => page}, socket) do
      {:noreply, push_redirect(socket, to: Routes.live_path(socket, DemoWeb.CounterLive.Product, page))}
    end

    def handle_event("open-cart", _, socket) do
      {:noreply, update(socket, :isCartOpen, &(!&1))}
    end

    def handle_event("inc", _, socket) do
      items = %{ name: "Phone added", count: 0}
      {:noreply, update(socket|> put_flash(:info, "user created"), :items, &(&1 = items))}
    end

    def handle_event("dec", username, socket) do
      {:noreply, update(socket, :val, &(&1 - 1))}
    end
end