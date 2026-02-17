defmodule ValentineWeb.WorkspaceLive.Components.ChatComponentTest do
  use ValentineWeb.ConnCase

  import Phoenix.LiveViewTest
  import Valentine.ComposerFixtures

  alias ValentineWeb.WorkspaceLive.Components.ChatComponent

  defp create_component(_) do
    workspace = workspace_fixture()

    assigns = %{
      __changed__: %{},
      active_module: "some_active_module",
      active_action: "some_active_action",
      async_result: Phoenix.LiveView.AsyncResult.loading(),
      chain: %LangChain.Chains.LLMChain{},
      id: "chat-component",
      skills: [],
      workspace_id: workspace.id,
      current_user: "test_user@example.com"
    }

    socket = %Phoenix.LiveView.Socket{
      assigns: assigns
    }

    %{assigns: assigns, socket: socket}
  end

  defp create_test_socket(base_socket, workspace_id, user_id) do
    Map.put(
      base_socket,
      :assigns,
      Map.merge(base_socket.assigns, %{
        workspace_id: workspace_id,
        current_user: user_id,
        myself: "myself"
      })
    )
  end

  defp restore_chat_history(base_socket, workspace_id, user_id) do
    {:ok, restored_socket} =
      ChatComponent.update(
        %{
          active_module: "some_module",
          active_action: "some_action",
          workspace_id: workspace_id,
          current_user: user_id
        },
        %Phoenix.LiveView.Socket{assigns: Map.merge(base_socket.assigns, %{myself: "myself"})}
      )

    restored_socket
  end

  describe "render/1" do
    setup [:create_component]

    test "displays a blank slate if no messages exist", %{assigns: assigns} do
      html = render_component(ChatComponent, assigns)
      assert html =~ "Ask AI Assistant"
    end

    test "displas a message if messages exist", %{assigns: assigns} do
      assigns =
        Map.put(assigns, :chain, %{
          delta: nil,
          messages: [
            %LangChain.Message{
              role: :user,
              content: "Hello, world!"
            }
          ]
        })

      html = render_component(ChatComponent, assigns)
      assert html =~ "Hello, world!"
    end

    test "displays a message delta if it exists", %{assigns: assigns} do
      assigns =
        Map.put(assigns, :chain, %{
          delta: %LangChain.MessageDelta{
            role: :system,
            content: "{\"content\":\"I am a system"
          },
          messages: [
            %LangChain.Message{
              role: :user,
              content: "Hello, world!"
            }
          ]
        })

      html = render_component(ChatComponent, assigns)
      assert html =~ "I am a system"
    end

    test "displays skills buttons if skills are set", %{assigns: assigns} do
      assigns =
        Map.put(assigns, :skills, [
          %{
            "id" => "some_skill_id",
            "description" => "some_skill_description"
          }
        ])

      html = render_component(ChatComponent, assigns)
      assert html =~ "some_skill_id"
      assert html =~ "some_skill_description"
    end

    test "displays a chat input container", %{assigns: assigns} do
      html = render_component(ChatComponent, assigns)
      assert html =~ "Ask AI Assistant"
    end
  end

  describe "mount/1" do
    setup [:create_component]

    test "properly assigns all the right values", %{socket: socket} do
      socket = Map.put(socket, :assigns, Map.put(socket.assigns, :myself, %{}))
      {:ok, updated_socket} = ChatComponent.mount(socket)
      assert updated_socket.assigns.skills == []
      assert updated_socket.assigns.usage == nil
      assert updated_socket.assigns.async_result.loading == true
    end
  end

  describe "update/2" do
    setup [:create_component]

    test "updates the socket with the chat_complete data", %{socket: socket} do
      data = %{
        content:
          Jason.encode!(%{
            "skills" => [
              %{
                "id" => "some_skill_id",
                "description" => "some_skill_description"
              }
            ]
          })
      }

      {:ok, updated_socket} = ChatComponent.update(%{chat_complete: data}, socket)
      assert updated_socket.assigns.skills == Jason.decode!(data.content)["skills"]
    end

    test "updates the socket with the chat_response delta data", %{socket: socket} do
      data =
        %LangChain.MessageDelta{
          role: :system,
          content: "{\"content\":\"I am a system"
        }

      {:ok, updated_socket} = ChatComponent.update(%{chat_response: data}, socket)
      assert updated_socket.assigns.chain.delta == data
    end

    test "updates the socket with the skill_result data", %{socket: socket} do
      data = %{
        id: "some_id",
        status: "some_status",
        msg: "some_msg"
      }

      {:ok, updated_socket} = ChatComponent.update(%{skill_result: data}, socket)

      assert hd(updated_socket.assigns.chain.messages).content ==
               "The user clicked the button with id: some_id and the result was: some_status - some_msg"
    end

    test "updates the socket with the usage_update data", %{socket: socket} do
      usage = %LangChain.TokenUsage{}
      {:ok, updated_socket} = ChatComponent.update(%{usage_update: usage}, socket)
      assert updated_socket.assigns.usage == usage
    end

    test "updates the socket with any assigns", %{socket: socket} do
      socket = Map.put(socket, :assigns, Map.put(socket.assigns, :myself, %{}))

      assigns = %{
        active_module: "some_active_module",
        active_action: "some_active_action",
        workspace_id: socket.assigns.workspace_id,
        current_user: socket.assigns.current_user,
        some_key: "some_value"
      }

      {:ok, updated_socket} = ChatComponent.update(assigns, socket)
      assert updated_socket.assigns.some_key == "some_value"
    end

    test "restores chat history per user and workspace across sessions", %{socket: socket} do
      workspace1 = workspace_fixture()
      workspace2 = workspace_fixture()
      user1 = "user1@example.com"
      user2 = "user2@example.com"

      # Register cleanup before any cache operations
      on_exit(fn ->
        Valentine.Cache.delete({workspace1.id, user1, :chatbot_history})
        Valentine.Cache.delete({workspace1.id, user2, :chatbot_history})
        Valentine.Cache.delete({workspace2.id, user1, :chatbot_history})
      end)

      # Submit messages in three different contexts
      socket1 = create_test_socket(socket, workspace1.id, user1)

      {:noreply, _} =
        ChatComponent.handle_event(
          "chat_submit",
          %{"value" => "User1 Workspace1 message"},
          socket1
        )

      socket2 = create_test_socket(socket, workspace1.id, user2)

      {:noreply, _} =
        ChatComponent.handle_event(
          "chat_submit",
          %{"value" => "User2 Workspace1 message"},
          socket2
        )

      socket3 = create_test_socket(socket, workspace2.id, user1)

      {:noreply, _} =
        ChatComponent.handle_event(
          "chat_submit",
          %{"value" => "User1 Workspace2 message"},
          socket3
        )

      # Verify each context restores its own history
      restored_socket1 = restore_chat_history(socket, workspace1.id, user1)
      restored_socket2 = restore_chat_history(socket, workspace1.id, user2)
      restored_socket3 = restore_chat_history(socket, workspace2.id, user1)

      assert Enum.at(restored_socket1.assigns.chain.messages, 1).content ==
               "User1 Workspace1 message"

      assert Enum.at(restored_socket2.assigns.chain.messages, 1).content ==
               "User2 Workspace1 message"

      assert Enum.at(restored_socket3.assigns.chain.messages, 1).content ==
               "User1 Workspace2 message"
    end
  end

  describe "handle_async/3" do
    setup [:create_component]

    test "updates the socket with the async_result", %{socket: socket} do
      async_fun_result = {:ok, "some_result"}

      {:noreply, updated_socket} =
        ChatComponent.handle_async(:running_llm, async_fun_result, socket)

      assert updated_socket.assigns.async_result.ok? == true
      assert updated_socket.assigns.async_result.result == "some_result"

      async_fun_result = {:error, "some_error"}

      {:noreply, updated_socket} =
        ChatComponent.handle_async(:running_llm, async_fun_result, socket)

      assert updated_socket.assigns.async_result.ok? == false
      assert updated_socket.assigns.async_result.failed == "some_error"
    end
  end

  describe "handle_event/3" do
    setup [:create_component]

    test "clears the existing messages from the llm chain if the value is /clear",
         %{socket: socket} do
      value = "/clear"

      socket =
        Map.put(
          socket,
          :assigns,
          Map.put(socket.assigns, :chain, %{
            messages: [
              %LangChain.Message{
                role: :system,
                content: "I am a system"
              },
              %LangChain.Message{
                role: :user,
                content: "Hello, world!"
              }
            ]
          })
        )

      socket =
        Map.put(
          socket,
          :assigns,
          Map.put(socket.assigns, :myself, "myself")
        )

      {:noreply, updated_socket} =
        ChatComponent.handle_event("chat_submit", %{"value" => value}, socket)

      assert length(updated_socket.assigns.chain.messages) == 0
    end

    test "adds a new system and user message to the llm chain", %{socket: socket} do
      value = "Hello, world!"

      {:noreply, updated_socket} =
        ChatComponent.handle_event("chat_submit", %{"value" => value}, socket)

      assert length(updated_socket.assigns.chain.messages) == 2
      assert hd(updated_socket.assigns.chain.messages).role == :system
      assert hd(tl(updated_socket.assigns.chain.messages)).role == :user
      assert hd(tl(updated_socket.assigns.chain.messages)).content == value
    end

    test "executes skills if the id is a skill", %{socket: socket} do
      socket =
        Map.put(
          socket,
          :assigns,
          Map.put(socket.assigns, :skills, [
            %{
              "id" => "some_skill_id",
              "description" => "some_skill_description"
            }
          ])
        )

      id = "some_skill_id"

      {:noreply, updated_socket} =
        ChatComponent.handle_event("execute_skill", %{"id" => id}, socket)

      assert updated_socket.assigns.skills == []
      refute Map.has_key?(updated_socket.assigns, :flash)
    end

    test "does not execute skills if the id is not a skill", %{socket: socket} do
      id = "some_id"

      {:noreply, updated_socket} =
        ChatComponent.handle_event("execute_skill", %{"id" => id}, socket)

      assert updated_socket.assigns.skills == []
    end
  end

  describe "run_chain/1" do
    setup [:create_component]

    test "runs the chain", %{socket: socket} do
      updated_socket = ChatComponent.run_chain(socket)
      assert updated_socket.assigns.chain != nil
    end
  end
end
