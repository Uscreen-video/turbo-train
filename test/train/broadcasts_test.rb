require "test_helper"

class BroadcastsTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper, Turbo::Streams::ActionHelper, Turbo::Train::TestHelper

  test "broadcasting render" do
    user_john = User.create! name: "John"
    user_bob = User.create! name: "Bob"

    message_1 = Message.create! user: user_john, text: "Hey Bob!"

    r = Turbo::Train.broadcast_render_to( message_1, partial: 'messages/message', locals: { message: message_1 } )
    assert_broadcast_on
    assert_equal r.code, '200'
    assert_match /urn:uuid:.*/, r.body
  end

  test "broadcasting action" do
    train_assert_broadcast_on 'messages', turbo_stream_action_tag("append", target: "target", template: 'content') do
      r = Turbo::Train.broadcast_append_to('messages', target: 'target', content: 'content')
      assert_equal r.code, '200'
      assert_match /urn:uuid:.*/, r.body
    end
    # BROADCAST_TO_METHODS = %w(broadcast_append_to broadcast_remove_to broadcast_replace_to broadcast_update_to broadcast_before_to broadcast_after_to broadcast_prepend_to).freeze
    #
    # BROADCAST_TO_METHODS.each do |method|
    #   assert_respond_to Turbo::Train, method
    #
    #   r = Turbo::Train.public_send(method, 'messages', target: 'target', content: 'content')
    #
    #   assert_equal r.code, '200'
    #   assert_match /urn:uuid:.*/, r.body
    # end
  end

  test "broadcasting action later" do
    BROADCAST_LATER_TO_METHODS = %w(
      broadcast_replace_later_to broadcast_remove_later_to broadcast_update_later_to
      broadcast_before_later_to broadcast_after_later_to
      broadcast_append_later_to broadcast_prepend_later_to
    ).freeze

    BROADCAST_LATER_TO_METHODS.each do |method|
      assert_respond_to Turbo::Train, method

      Turbo::Train.public_send(method, 'messages', target: 'target', content: 'content')
    end

    assert_enqueued_jobs BROADCAST_LATER_TO_METHODS.size
  end
end