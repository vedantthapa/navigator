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

  describe "chat history persistence" do
    setup [:create_component]

    test "persists chat history across socket sessions", %{socket: socket} do
      workspace_id = socket.assigns.workspace_id
      user_id = socket.assigns.current_user

      # Clear any existing cache for this user/workspace
      Valentine.Cache.delete({workspace_id, user_id, :chatbot_history})

      # Simulate first session: submit a chat message
      value = "Hello, world!"

      {:noreply, first_socket} =
        ChatComponent.handle_event("chat_submit", %{"value" => value}, socket)

      # Verify messages were added to the chain
      assert length(first_socket.assigns.chain.messages) == 2
      first_messages = first_socket.assigns.chain.messages

      # Verify messages were cached
      cached_messages = Valentine.Cache.get({workspace_id, user_id, :chatbot_history})
      assert cached_messages != nil
      assert length(cached_messages) == 2

      # Simulate second session: create new socket and update component
      # This simulates a socket reconnection/remount
      new_socket = %Phoenix.LiveView.Socket{
        assigns: Map.put(socket.assigns, :myself, %{})
      }

      assigns = %{
        workspace_id: workspace_id,
        current_user: user_id,
        active_module: "some_active_module",
        active_action: "some_active_action"
      }

      {:ok, updated_socket} = ChatComponent.update(assigns, new_socket)

      # Verify the cached messages were loaded into the new socket
      assert length(updated_socket.assigns.chain.messages) == 2
      assert updated_socket.assigns.chain.messages == first_messages

      # Cleanup
      Valentine.Cache.delete({workspace_id, user_id, :chatbot_history})
    end

    test "isolates chat history per user and workspace combination", %{socket: socket} do
      workspace1_id = socket.assigns.workspace_id
      workspace2 = workspace_fixture()
      workspace2_id = workspace2.id

      user1_id = "user1@example.com"
      user2_id = "user2@example.com"

      # Clear any existing cache
      Valentine.Cache.delete({workspace1_id, user1_id, :chatbot_history})
      Valentine.Cache.delete({workspace1_id, user2_id, :chatbot_history})
      Valentine.Cache.delete({workspace2_id, user1_id, :chatbot_history})

      # Create messages for user1 in workspace1
      message1 = "User1 in Workspace1"

      socket1 =
        socket
        |> Map.put(:assigns, Map.merge(socket.assigns, %{current_user: user1_id}))

      {:noreply, _socket1_updated} =
        ChatComponent.handle_event("chat_submit", %{"value" => message1}, socket1)

      # Create messages for user2 in workspace1
      message2 = "User2 in Workspace1"

      socket2 =
        socket
        |> Map.put(:assigns, Map.merge(socket.assigns, %{current_user: user2_id}))

      {:noreply, _socket2_updated} =
        ChatComponent.handle_event("chat_submit", %{"value" => message2}, socket2)

      # Create messages for user1 in workspace2
      message3 = "User1 in Workspace2"

      socket3 =
        socket
        |> Map.put(
          :assigns,
          Map.merge(socket.assigns, %{workspace_id: workspace2_id, current_user: user1_id})
        )

      {:noreply, _socket3_updated} =
        ChatComponent.handle_event("chat_submit", %{"value" => message3}, socket3)

      # Verify each combination has separate cached messages
      cached1 = Valentine.Cache.get({workspace1_id, user1_id, :chatbot_history})
      cached2 = Valentine.Cache.get({workspace1_id, user2_id, :chatbot_history})
      cached3 = Valentine.Cache.get({workspace2_id, user1_id, :chatbot_history})

      assert cached1 != nil
      assert cached2 != nil
      assert cached3 != nil

      # Verify the messages are different and contain the correct content
      assert Enum.any?(cached1, fn msg -> msg.content == message1 end)
      assert Enum.any?(cached2, fn msg -> msg.content == message2 end)
      assert Enum.any?(cached3, fn msg -> msg.content == message3 end)

      # Verify user1's message in workspace1 is NOT in user2's cache
      refute Enum.any?(cached2, fn msg -> msg.content == message1 end)

      # Verify user1's message in workspace1 is NOT in user1's workspace2 cache
      refute Enum.any?(cached3, fn msg -> msg.content == message1 end)

      # Verify user2's message is NOT in user1's workspace1 cache
      refute Enum.any?(cached1, fn msg -> msg.content == message2 end)

      # Cleanup
      Valentine.Cache.delete({workspace1_id, user1_id, :chatbot_history})
      Valentine.Cache.delete({workspace1_id, user2_id, :chatbot_history})
      Valentine.Cache.delete({workspace2_id, user1_id, :chatbot_history})
    end
  end
end
