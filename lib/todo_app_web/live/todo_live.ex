defmodule TodoAppWeb.TodoLive do
  use TodoAppWeb, :live_view

  alias TodoApp.Todos

  def mount(_params, _session, socket) do
    {:ok, fetch(socket)}
  end

  def render(assigns) do
    ~L"""
      <h1>Todo List</h1>
      <%= form_for @changeset,
          "#",
          [
            id: "todo-form",
            phx_submit: "add-todo",
            phx_change: "validate"
          ], fn f -> %>
        <%= text_input :todo,
            :title,
            placeholder: "Create a todo" %>
        <%= error_tag f, :title %>
        <%= submit "Add", phx_disable_with: "Adding..." %>
      <% end %>
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
      <%= if @show_edit_modal do %>
        <%= live_modal @socket,
            TodoAppWeb.FormComponent,
            id: @todo.id,
            title: "Edit",
            action: @live_action,
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

  def handle_event("add-todo", %{"todo" => params}, socket) do
    case Todos.create_todo(params) do
      {:ok, _todo} ->
        {:noreply, fetch(socket)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"todo" => params}, socket) do
    changeset =
      %TodoApp.Todos.Todo{}
      |> Todos.change_todo(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("delete-todo", %{"todo-id" => id}, socket) do
    todo = Todos.get_todo!(id)

    {:ok, _} = Todos.delete_todo(todo)

    {:noreply, fetch(socket)}
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

  def handle_params(_params, _uri, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    socket
    |> assign(:changeset, Todos.change_todo(%TodoApp.Todos.Todo{}))
    |> assign(:todos, Todos.list_todos())
    |> assign(:show_edit_modal, false)
  end
end
