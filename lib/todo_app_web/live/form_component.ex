defmodule TodoAppWeb.FormComponent do
  use TodoAppWeb, :live_component

  alias TodoApp.Todos

  def render(assigns) do
    ~L"""
      <%= form_for @changeset,
          "#",
          [
            id: "todo-form",
            phx_target: @myself,
            phx_change: "validate",
            phx_submit: "save"
          ], fn f -> %>
        <%= text_input f,
            :title,
            placeholder: "Create a todo" %>
        <%= error_tag f, :title %>
        <%= submit "Save", phx_disable_with: "Saving..." %>
      <% end %>
    """
  end

  def update(%{todo: todo} = assigns, socket) do
    changeset = Todos.change_todo(todo)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  def handle_event("validate", %{"todo" => params}, socket) do
    changeset =
      %TodoApp.Todos.Todo{}
      |> Todos.change_todo(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"todo" => todo_params}, socket) do
    save_todo(socket, socket.assigns.action, todo_params)
  end

  defp save_todo(socket, :new, todo_params) do
    case Todos.create_todo(todo_params) do
      {:ok, _todo} ->
        {:noreply,
         socket
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp save_todo(socket, :edit, todo_params) do
    case Todos.update_todo(socket.assigns.todo, todo_params) do
      {:ok, _todo} ->
        {:noreply,
         socket
         |> put_flash(:info, "Todo updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
