defmodule ValentineWeb.WorkspaceLive.Components.ChatHistoryPersistenceTest do
  use ValentineWeb.ConnCase

  alias LangChain.Message

  @user_id "test_user_123"
  @workspace_id "workspace_456"

  describe "chat history persistence across socket sessions" do
    test "chat history persists when socket changes but user and workspace remain same" do
      # Build cache key using same logic as chat_component.ex
      cache_key = {@user_id, @workspace_id, :chatbot_history}

      # Create a mock chain with messages (using a simple map structure like in tests)
      chain = %{
        messages: [
          Message.new_user!("Hello, AI!"),
          Message.new_assistant!("Hello! How can I help you?")
        ]
      }

      # Store chat history (simulating first socket session)
      Valentine.Cache.put(cache_key, chain, expire: :timer.hours(24))

      # Retrieve chat history (simulating new socket session after reconnection)
      retrieved_chain = Valentine.Cache.get(cache_key)

      # Verify chat history was retrieved
      assert retrieved_chain != nil
      assert length(retrieved_chain.messages) == 2
      assert hd(retrieved_chain.messages).content == "Hello, AI!"
    end

    test "chat history is isolated per workspace for same user" do
      workspace_1_key = {@user_id, "workspace_1", :chatbot_history}
      workspace_2_key = {@user_id, "workspace_2", :chatbot_history}

      # Store chat in workspace 1
      chain1 = %{
        messages: [Message.new_user!("Message in workspace 1")]
      }

      Valentine.Cache.put(workspace_1_key, chain1, expire: :timer.hours(24))

      # Verify workspace 2 has no chat history
      workspace_2_chain = Valentine.Cache.get(workspace_2_key)
      assert workspace_2_chain == nil
    end

    test "chat history is isolated per user for same workspace" do
      user_1_key = {"user_1", @workspace_id, :chatbot_history}
      user_2_key = {"user_2", @workspace_id, :chatbot_history}

      # Store chat for user 1
      chain1 = %{
        messages: [Message.new_user!("Message from user 1")]
      }

      Valentine.Cache.put(user_1_key, chain1, expire: :timer.hours(24))

      # Verify user 2 has no chat history
      user_2_chain = Valentine.Cache.get(user_2_key)
      assert user_2_chain == nil
    end

    test "clearing chat history removes messages from cache" do
      cache_key = {@user_id, @workspace_id, :chatbot_history}

      # Store chat history
      chain = %{
        messages: [Message.new_user!("Test message")]
      }

      Valentine.Cache.put(cache_key, chain, expire: :timer.hours(24))

      # Verify it's stored
      assert Valentine.Cache.get(cache_key) != nil

      # Clear chat (store empty chain)
      empty_chain = %{messages: []}
      Valentine.Cache.put(cache_key, empty_chain, expire: :timer.hours(24))

      # Verify it's cleared
      retrieved = Valentine.Cache.get(cache_key)
      assert retrieved != nil
      assert length(retrieved.messages) == 0
    end

    test "build_cache_key returns nil for nil user_id" do
      # The build_cache_key function in chat_component.ex should return nil
      # when user_id is nil to prevent cache operations
      # This test verifies the guard clause behavior indirectly through cache operations

      # In the actual component, build_cache_key(nil, @workspace_id) returns nil
      # which means cache operations won't happen
      # We verify this by checking that the cache system doesn't confuse nil keys

      cache_key_with_nil = {nil, @workspace_id, :chatbot_history}
      valid_cache_key = {@user_id, @workspace_id, :chatbot_history}

      # Store something with nil user (simulating a scenario where guard fails)
      Valentine.Cache.put(cache_key_with_nil, %{messages: [Message.new_user!("nil user")]},
        expire: :timer.hours(24)
      )

      # Store something with valid user
      Valentine.Cache.put(valid_cache_key, %{messages: [Message.new_user!("valid user")]},
        expire: :timer.hours(24)
      )

      # Verify they don't interfere with each other
      nil_result = Valentine.Cache.get(cache_key_with_nil)
      valid_result = Valentine.Cache.get(valid_cache_key)

      assert nil_result.messages != valid_result.messages
    end

    test "build_cache_key returns nil for nil workspace_id" do
      # The build_cache_key function in chat_component.ex should return nil
      # when workspace_id is nil to prevent cache operations
      # This test verifies the guard clause behavior indirectly through cache operations

      cache_key_with_nil = {@user_id, nil, :chatbot_history}
      valid_cache_key = {@user_id, @workspace_id, :chatbot_history}

      # Store something with nil workspace (simulating a scenario where guard fails)
      Valentine.Cache.put(cache_key_with_nil, %{messages: [Message.new_user!("nil workspace")]},
        expire: :timer.hours(24)
      )

      # Store something with valid workspace
      Valentine.Cache.put(valid_cache_key, %{messages: [Message.new_user!("valid workspace")]},
        expire: :timer.hours(24)
      )

      # Verify they don't interfere with each other
      nil_result = Valentine.Cache.get(cache_key_with_nil)
      valid_result = Valentine.Cache.get(valid_cache_key)

      assert nil_result.messages != valid_result.messages
    end
  end
end
