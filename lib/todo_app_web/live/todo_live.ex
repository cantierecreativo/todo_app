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
          <li>
            <%= content_tag :input,
                nil,
                type: "checkbox",
                phx_click: "toggle-todo",
                phx_value_todo_id: todo.id,
                checked: todo.completed %>
            <%= todo.title %>
          </li>
        <% end %>
      </ul>
    """
  end

  def handle_event("toggle-todo", %{"todo-id" => id}, socket) do
    todo = Todos.get_todo!(id)

    {:ok, _} = Todos.update_todo(todo, %{completed: !todo.completed})

    {:noreply, socket}
  end

  defp fetch(socket) do
    assign(socket, %{todos: Todos.list_todos()})
  end
end
