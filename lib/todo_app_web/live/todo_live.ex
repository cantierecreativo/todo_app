defmodule TodoAppWeb.TodoLive do
  use TodoAppWeb, :live_view

  alias TodoApp.Todos

  def mount(_params, _session, socket) do
    {:ok, fetch(socket)}
  end

  def render(assigns) do
    ~L"""
      <h1>Todo List</h1>
      <ul>
        <%= for todo <- @todos do %>
          <li><%= todo.title %></li>
        <% end %>
      </ul>
    """
  end

  defp fetch(socket) do
    assign(socket, %{todos: Todos.list_todos()})
  end
end
