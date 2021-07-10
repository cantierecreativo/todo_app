defmodule TodoAppWeb.TodoLive do
  use TodoAppWeb, :live_view

  alias TodoApp.Todos

  def mount(_params, _session, socket) do
    {:ok, fetch(socket)}
  end

  def render(assigns) do
    ~L"""
      <h1>Todo List</h1>
      <%= live_component @socket,
          TodoAppWeb.FormComponent,
          id: "todo-form",
          action: :new,
          todo: @todo,
          return_to: Routes.live_path(@socket, TodoAppWeb.TodoLive) %>
      <ul phx-hook="InitSortable" id="items" data-target-id="#items">
        <%= for todo <- @todos do %>
          <li data-sortable-id=<%=todo.id %>>
            <%= content_tag :input,
                nil,
                type: "checkbox",
                phx_click: "toggle-todo",
                phx_value_todo_id: todo.id,
                checked: todo.completed %>
            <%= todo.title %>
            <%= live_patch "Edit",
                to: Routes.live_path(@socket, TodoAppWeb.TodoLive, %{edit: todo.id}) %>
            <%= link "Delete",
                to: "#",
                phx_click: "delete-todo",
                phx_value_todo_id: todo.id,
                data: [confirm: "Are you sure?"] %>
          </li>
        <% end %>
      </ul>
      <footer>
        <%= live_patch "All",
            to: Routes.live_path(@socket, TodoAppWeb.TodoLive),
            class: "button" %>
        <%= live_patch "Completed",
            to: Routes.live_path(@socket, TodoAppWeb.TodoLive, %{filter: "completed"}),
            class: "button" %>
      </footer>
      <%= if @show_edit_modal do %>
        <%= live_modal @socket,
            TodoAppWeb.FormComponent,
            id: @todo.id,
            title: "Edit",
            action: :edit,
            todo: @todo,
            return_to: Routes.live_path(@socket, TodoAppWeb.TodoLive) %>
      <% end %>
    """
  end

  def handle_event("toggle-todo", %{"todo-id" => id}, socket) do
    todo = Todos.get_todo!(id)

    {:ok, _} = Todos.update_todo(todo, %{completed: !todo.completed})

    {:noreply, socket}
  end

  def handle_event("delete-todo", %{"todo-id" => id}, socket) do
    todo = Todos.get_todo!(id)

    {:ok, _} = Todos.delete_todo(todo)

    {:noreply, fetch(socket)}
  end

  def handle_event("sort", %{"list" => list}, socket) do
    list
    |> Enum.each(fn %{"id" => id, "position" => position} ->
      Todos.get_todo!(id)
      |> Todos.update_todo(%{"position" => position})
    end)

    {:noreply, socket}
  end

  def handle_params(%{"edit" => id}, _uri, socket) do
    todo = Todos.get_todo(id)

    case todo do
      nil ->
        {:noreply,
         socket
         |> put_flash(:info, "Todo not found")}
      _ ->
        {:noreply,
         socket
         |> assign(:show_edit_modal, true)
         |> assign(:todo, todo)}
    end
  end

  def handle_params(%{"filter" => filter}, _uri, socket) do
    {:noreply,
     socket
     |> assign(:todos, Todos.list_completed_todos())
     |> assign(:filter, filter)
    }
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    socket
    |> assign(:changeset, Todos.change_todo(%TodoApp.Todos.Todo{}))
    |> assign(:todos, Todos.list_todos())
    |> assign(:todo, %TodoApp.Todos.Todo{})
    |> assign(:show_edit_modal, false)
  end
end
