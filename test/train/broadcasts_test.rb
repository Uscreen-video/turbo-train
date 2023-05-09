require "test_helper"

class BroadcastsTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper, Turbo::Streams::ActionHelper, Turbo::Train::TestHelper

  test "broadcasting render" do
    user_john = User.create! name: "John"

    message = Message.create! user: user_john, text: "Hey Bob!"

    assert_broadcast_on "messages", turbo_stream_action_tag("replace", target: "message_1", template: "Goodbye!") do
      r = Turbo::Train.broadcast_render_to("messages", partial: 'messages/message', locals: { message: message })

      assert_equal r.code, '200'
      assert_match /urn:uuid:.*/, r.body
    end
  end

  test "broadcast_action_to" do
    assert_broadcast_on 'messages', turbo_stream_action_tag("replace", target: "target", template: 'content') do
      r = Turbo::Train.broadcast_action_to('messages', action: 'replace', target: 'target', content: 'content')
      assert_equal r.code, '200'
      assert_match /urn:uuid:.*/, r.body
    end
  end

  test "broadcast_append_to" do
    assert_broadcast_on 'messages', turbo_stream_action_tag("append", target: "target", template: 'content') do
      r = Turbo::Train.broadcast_append_to('messages', target: 'target', content: 'content')
      assert_equal r.code, '200'
      assert_match /urn:uuid:.*/, r.body
    end
  end

  test "broadcast_remove_to" do
    assert_broadcast_on 'messages', turbo_stream_action_tag("remove", target: "target", template: 'content') do
      r = Turbo::Train.broadcast_remove_to('messages', target: 'target', content: 'content')
      assert_equal r.code, '200'
      assert_match /urn:uuid:.*/, r.body
    end
  end

  test "broadcast_replace_to" do
    assert_broadcast_on 'messages', turbo_stream_action_tag("replace", target: "target", template: 'content') do
      r = Turbo::Train.broadcast_replace_to('messages', target: 'target', content: 'content')
      assert_equal r.code, '200'
      assert_match /urn:uuid:.*/, r.body
    end
  end

  test "broadcast_update_to" do
    assert_broadcast_on 'messages', turbo_stream_action_tag("update", target: "target", template: 'content') do
      r = Turbo::Train.broadcast_update_to('messages', target: 'target', content: 'content')
      assert_equal r.code, '200'
      assert_match /urn:uuid:.*/, r.body
    end
  end

  test "broadcast_before_to" do
    assert_broadcast_on 'messages', turbo_stream_action_tag("before", target: "target", template: 'content') do
      r = Turbo::Train.broadcast_before_to('messages', target: 'target', content: 'content')
      assert_equal r.code, '200'
      assert_match /urn:uuid:.*/, r.body
    end
  end

  test "broadcast_after_to" do
    assert_broadcast_on 'messages', turbo_stream_action_tag("after", target: "target", template: 'content') do
      r = Turbo::Train.broadcast_after_to('messages', target: 'target', content: 'content')
      assert_equal r.code, '200'
      assert_match /urn:uuid:.*/, r.body
    end
  end

  test "broadcast_prepend_to" do
    assert_broadcast_on 'messages', turbo_stream_action_tag("prepend", target: "target", template: 'content') do
      r = Turbo::Train.broadcast_prepend_to('messages', target: 'target', content: 'content')
      assert_equal r.code, '200'
      assert_match /urn:uuid:.*/, r.body
    end
  end

  # later

  test "broadcast_replace_later_to" do
    assert_broadcast_on 'messages', turbo_stream_action_tag("replace", target: "target", template: 'content') do
      perform_enqueued_jobs do
        Turbo::Train.broadcast_replace_later_to('messages', target: 'target', content: 'content')
      end
    end
  end

  test "broadcast_remove_later_to" do
    assert_broadcast_on 'messages', turbo_stream_action_tag("remove", target: "target", template: 'content') do
      perform_enqueued_jobs do
        Turbo::Train.broadcast_remove_later_to('messages', target: 'target', content: 'content')
      end
    end
  end

  test "broadcast_update_later_to" do
    assert_broadcast_on 'messages', turbo_stream_action_tag("update", target: "target", template: 'content') do
      perform_enqueued_jobs do
        Turbo::Train.broadcast_update_later_to('messages', target: 'target', content: 'content')
      end
    end
  end

  test "broadcast_before_later_to" do
    assert_broadcast_on 'messages', turbo_stream_action_tag("before", target: "target", template: 'content') do
      perform_enqueued_jobs do
        Turbo::Train.broadcast_before_later_to('messages', target: 'target', content: 'content')
      end
    end
  end

  test "broadcast_after_later_to" do
    assert_broadcast_on 'messages', turbo_stream_action_tag("after", target: "target", template: 'content') do
      perform_enqueued_jobs do
        Turbo::Train.broadcast_after_later_to('messages', target: 'target', content: 'content')
      end
    end
  end

  test "broadcast_append_later_to" do
    assert_broadcast_on 'messages', turbo_stream_action_tag("append", target: "target", template: 'content') do
      perform_enqueued_jobs do
        Turbo::Train.broadcast_append_later_to('messages', target: 'target', content: 'content')
      end
    end
  end

  test "broadcast_prepend_later_to" do
    assert_broadcast_on 'messages', turbo_stream_action_tag("prepend", target: "target", template: 'content') do
      perform_enqueued_jobs do
        Turbo::Train.broadcast_prepend_later_to('messages', target: 'target', content: 'content')
      end
    end
  end

  test "broadcast_action_later_to" do
    assert_broadcast_on 'messages', turbo_stream_action_tag("replace", target: "target", template: 'content') do
      perform_enqueued_jobs do
        Turbo::Train.broadcast_action_later_to('messages', action: 'replace', target: 'target', content: 'content')
      end
    end
  end

  test "broadcast_render_later_to" do
    user_john = User.create! name: "John"

    message = Message.create! user: user_john, text: "Hey Bob!"

    assert_broadcast_on "messages", turbo_stream_action_tag("replace", target: "message_1", template: "Goodbye!") do
      perform_enqueued_jobs do
        Turbo::Train.broadcast_render_later_to("messages", partial: 'messages/message', locals: { message: message })
      end
    end
  end
end