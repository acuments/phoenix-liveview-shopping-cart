defmodule DemoWeb.CounterLive.Index do
    use Phoenix.LiveView
    import Redis
    alias DemoWeb.Router.Helpers, as: Routes
    alias DemoWeb.Store, as: Store
 
    @items([])

    def render(assigns) do
    ~L"""
    <div class="component-container">
        <%= live_component(@socket, DemoWeb.HeaderComponent, id: "Header Component", items: @items, isCartOpen: @isCartOpen ) %>
      <div class="product-container product-header">
      <div class="card-box">
      <div class="cardcontainer">
        <%= for phone <- @phones do %>
          <div class="card">
          <a  href="/live/product/<%= phone.id%>" class="link-style"><p class="card-heading"><%= phone.name %></p>
          <img src=<%= phone.image%> class="image"/>
          <p>Price: $<%= phone.price %></p></a>
          <div class="button-group">
            <button phx-click="inc" phx-value-name="<%= phone.name %>" phx-value-price="<%= phone.price %>" class="button-style" >Add to cart</button>
          </div>
          </div>
        <% end %>
      </div>
      </div>
      </div>
      </div>
    """
    #   DemoWeb.CounterView.render("index.html", assigns)
    end

    def mount(_params, _session, socket) do
      Store.init
      {_, cache} = Cachex.get(:my_cache, "global")
      {:ok, assign(
          socket,
          phones: Store.getPhones,
          isCartOpen: false,
          items: cache.items,
          phoneCount: Enum.count(Store.getPhones),
          perPage: nil,
          page: 1,
        )}
    end

    def handle_event("delete-item", %{"name" => name}, socket) do
      items = socket.assigns.items
      mod_items = Enum.filter(items, fn(item) ->
        item.name != name
      end)
      {_, cache} = Cachex.get(:my_cache, "global")
      cache = Map.put(cache, :items, mod_items)
      Cachex.put(:my_cache, "global", cache)
      {:noreply, update(socket, :items, &(&1 = mod_items))}
    end

    def handle_event("close-cart", _, socket) do
      {:noreply, update(socket, :isCartOpen, &(&1 = false))}
    end

    def handle_event("open-cart", _, socket) do
      {:noreply, update(socket, :isCartOpen, &(!&1))}
    end

    def handle_event("inc", %{"name" => name, "price" => price}, socket) do
      items = socket.assigns.items
      test = true
      mod_items = Enum.map(items, fn(item) -> 
        if (item.name === name) do
          %{
            name: item.name,
            count: item.count + 1,
            price: item.price
          }
        else
          item
        end
      end)
      socket = assign(socket, :items, mod_items)
      if (socket.changed === %{} or !socket.changed.items) do
        items = mod_items ++ [%{ name: name, count: 1, price: price}]
        {_, cache} = Cachex.get(:my_cache, "global")
        cache = Map.put(cache, :items, items)
        Cachex.set(:my_cache, "global", cache)
        {:noreply, update(socket, :items, &(&1 = items))}
      else
        {_, cache} = Cachex.get(:my_cache, "global")
        cache = Map.put(cache, :items, mod_items)
        Cachex.set(:my_cache, "global", cache)
        {:noreply, update(socket, :items, &(&1 = mod_items))}
      end
    end

    def handle_event("dec", %{"name" => name}, socket) do
      items = socket.assigns.items
      mod_items = Enum.map(items, fn(item) ->
        if (item.name === name) do
          %{
            name: item.name,
            count: item.count - 1,
            price: item.price
          }
        else
         item
        end
      end)
      after_remove = Enum.filter(mod_items, fn(item) ->
        item.count !== 0
      end)
      {_, cache} = Cachex.get(:my_cache, "global")
      cache = Map.put(cache, :items, after_remove)
      Cachex.put(:my_cache, "global", cache)
      {:noreply, update(socket, :items, &(&1 = after_remove))}
    end
end