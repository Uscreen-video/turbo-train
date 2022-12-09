require "application_system_test_case"

class BroadcastingTest < ApplicationSystemTestCase
  test "Turbo::Train broadcasts Turbo Streams" do
    user_john = User.create! name: "John"
    user_bob = User.create! name: "Bob"

    message_1 = Message.create! user: user_john, text: "Hey Bob!"
    visit messages_path

    assert_no_javascript_errors do
      assert_text "Hey Bob!"
      sleep(2)

      Turbo::Train.broadcast_append_to('messages', target: 'messages', partial: 'messages/message', locals: { message: Message.create!(user: user_bob, text: "Hi John!") })
      sleep(2)
      assert_text "Hi John!"

      Turbo::Train.broadcast_prepend_to('messages', target: 'messages', html: '<p>Random7</p>')
      sleep(2)
      assert_text "Random7"

      Turbo::Train.broadcast_after_to('messages', target: 'messages', html: '<span>broadcast_after_to</span>')
      sleep(2)
      assert_text "broadcast_after_to"

      Turbo::Train.broadcast_before_to('messages', target: 'messages', html: '<span>broadcast_before_to</span>')
      sleep(2)
      assert_text "broadcast_before_to"

      Message.last.update!(text: "Hi John! How are you? [edited]")
      Turbo::Train.broadcast_update_to('messages', target: Message.last.id, partial: 'messages/message', locals: { message: Message.last })
      sleep(2)
      assert_text "Hi John! How are you? [edited]"

      Message.last.update!(text: "Hi John! How's it going? [edited]")
      Turbo::Train.broadcast_replace_to('messages', target: Message.last.id, partial: 'messages/message', locals: { message: Message.last })
      sleep(2)
      assert_text "Hi John! How's it going? [edited]"

      Message.last.update!(text: "Hi John! How's it going? [edited]")
      Turbo::Train.broadcast_remove_to('messages', target: Message.last.id)
      sleep(2)
      assert_no_text "Hi John"

      Turbo::Train.broadcast_action_to('messages', action: :append, target: 'messages', html: "<p id='message'>2345</p>")
      sleep(2)
      assert_text "2345"
    end
  end
end
