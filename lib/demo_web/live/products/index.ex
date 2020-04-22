defmodule DemoWeb.ProductsLive.Index do
  use Phoenix.LiveView
  import Redis
  alias DemoWeb.Router.Helpers, as: Routes
  alias DemoWeb.Store, as: Store

  @items([])

  def render(assigns) do
    DemoWeb.ProductsView.render("index.html", assigns)
  end

  def mount(_params, _session, socket) do
    Store.init
    {_, cache} = Cachex.get(:my_cache, "global")
    {:ok, assign(
      socket,
      phones: Store.getPhones,
      isCartOpen: false,
      items: cache.items,
      phoneCount: Store.phoneCount,
      perPage: 4,
      page: 1,
      message: ""
    )}
  end

  def handle_event("select-page", %{"per_page" => per_page}, socket) do
    {perPage, _} = Integer.parse(per_page)
    {:noreply, assign(socket, phones: Store.getPhonesPerPage(perPage, 1), perPage: perPage, page: 1)}
  end

  def handle_event("load-more", _, socket) do
    phones = Store.getPhonesPerPage(socket.assigns.perPage, socket.assigns.page + 1)
    {:noreply, assign(socket, page: socket.assigns.page + 1, phones: phones)}
  end

  def handle_event("delete-item", %{"id" => id}, socket) do
    {:noreply, update(socket, :items, &(&1 = Store.deleteItemFromCart(id)))}
  end

  def handle_event("toggle-cart", _, socket) do
    {:noreply, update(socket, :isCartOpen, &(&1 = !socket.assigns.isCartOpen))}
  end

  def handle_event("inc", %{"id" => id}, socket) do
    searchItem = Store.getItemById(id)
    items = socket.assigns.items
    test = true
    mod_items = Enum.map(items, fn(item) ->
      if (item.id == String.to_integer(id)) do
        %{item | count: item.count + 1}
      else
        item
      end
    end)
    socket = assign(socket, :items, mod_items)
    if (socket.changed === %{} or !socket.changed.items) do
      items = mod_items ++ [ %{ searchItem | count: 1 } ]
      {_, cache} = Cachex.get(:my_cache, "global")
      cache = Map.put(cache, :items, items)
      Cachex.set(:my_cache, "global", cache)
      {:noreply, assign(socket, message: "Product Added To Cart Successfully", items: items)}
    else
      {_, cache} = Cachex.get(:my_cache, "global")
      cache = Map.put(cache, :items, mod_items)
      Cachex.set(:my_cache, "global", cache)
      {:noreply, assign(socket, message: "Product Added To Cart Successfully", items: mod_items)}
    end
  end

  def handle_event("dec", %{"id" => id}, socket) do
    after_remove = Store.decrementItemInCart(id)
    {:noreply, assign(socket, message: "Product Deleted From Cart Successfully!", items: after_remove)}
  end

  def handle_event("close-alert", _, socket) do
    {:noreply, assign(socket, message: "")}
  end
end