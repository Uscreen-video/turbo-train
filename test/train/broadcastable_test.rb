require "test_helper"

class BroadcastableTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper, Turbo::Streams::ActionHelper, Turbo::Train::TestHelper

  setup do
    @user = User.create! name: "John"
    @message = Message.create! user: @user, text: "Hey Bob!"
    @message.class.include Turbo::Train::Broadcastable
  end

  test 'train_broadcasts' do
    Message.class_eval do
      train_broadcasts content: 'content'
    end

    new_msg = nil
    assert_broadcast_on 'messages', turbo_stream_action_tag("append", target: "messages", template: "content") do
      perform_enqueued_jobs do
        new_msg = Message.create! user: @user, text: "Hey Bob!"
      end
    end

    assert_broadcast_on new_msg, turbo_stream_action_tag("replace", target: "message_#{new_msg.id}", template: "content") do
      perform_enqueued_jobs do
        new_msg.update!(text: "Hey Bob2!")
      end
    end

    assert_broadcast_on new_msg, turbo_stream_action_tag("remove", target: "message_#{new_msg.id}") do
      new_msg.destroy
    end
  end

  test 'train_broadcasts_to' do
    Message.class_eval do
      train_broadcasts_to :user, content: 'content'
    end

    new_msg = nil
    assert_broadcast_on @user, turbo_stream_action_tag("append", target: "messages", template: "content") do
      perform_enqueued_jobs do
        new_msg = Message.create! user: @user, text: "Hey Bob!"
      end
    end

    assert_broadcast_on @user, turbo_stream_action_tag("replace", target: "message_#{new_msg.id}", template: "content") do
      perform_enqueued_jobs do
        new_msg.update!(text: "Hey Bob2!")
      end
    end

    assert_broadcast_on @user, turbo_stream_action_tag("remove", target: "message_#{new_msg.id}") do
      new_msg.destroy
    end
  end


  test "train_broadcast_render_to" do
    assert_broadcast_on @message, turbo_stream_action_tag("replace", target: "message_1", template: "Goodbye!") do
      @message.train_broadcast_render_to @message
    end
  end

  test "train_broadcast_render" do
    assert_broadcast_on @message, turbo_stream_action_tag("replace", target: "message_1", template: "Goodbye!") do
      @message.train_broadcast_render
    end
  end

  test "broadcast_action_to" do
    assert_broadcast_on @message, turbo_stream_action_tag("replace", target: "target", template: 'content') do
      @message.train_broadcast_action_to(@message, action: 'replace', target: 'target', content: 'content')
    end
  end

  test "broadcast_action" do
    assert_broadcast_on @message, turbo_stream_action_tag("replace", target: "target", template: 'content') do
      @message.train_broadcast_action('replace', target: 'target', content: 'content')
    end
  end

  test "broadcast_append_to" do
    assert_broadcast_on @message, turbo_stream_action_tag("append", target: "target", template: 'content') do
      @message.train_broadcast_append_to(@message, target: 'target', content: 'content')
    end
  end

  test "broadcast_append" do
    assert_broadcast_on @message, turbo_stream_action_tag("append", target: "target", template: 'content') do
      @message.train_broadcast_append(target: 'target', content: 'content')
    end
  end

  test "broadcast_remove_to" do
    assert_broadcast_on @message, turbo_stream_action_tag("remove", target: "message_#{@message.id}") do
      @message.train_broadcast_remove_to(@message)
    end
  end

  test "broadcast_remove" do
    assert_broadcast_on @message, turbo_stream_action_tag("remove", target: "message_#{@message.id}") do
      @message.train_broadcast_remove
    end
  end

  test "broadcast_replace_to" do
    assert_broadcast_on @message, turbo_stream_action_tag("replace", target: "target", template: 'content') do
      @message.train_broadcast_replace_to(@message, target: 'target', content: 'content')
    end
  end

  test "broadcast_replace" do
    assert_broadcast_on @message, turbo_stream_action_tag("replace", target: "target", template: 'content') do
      @message.train_broadcast_replace(target: 'target', content: 'content')
    end
  end

  test "broadcast_update_to" do
    assert_broadcast_on @message, turbo_stream_action_tag("update", target: "target", template: 'content') do
      @message.train_broadcast_update_to(@message, target: 'target', content: 'content')
    end
  end

  test "broadcast_update" do
    assert_broadcast_on @message, turbo_stream_action_tag("update", target: "target", template: 'content') do
      @message.train_broadcast_update(target: 'target', content: 'content')
    end
  end

  test "broadcast_before_to" do
    assert_broadcast_on @message, turbo_stream_action_tag("before", target: "target", template: 'content') do
      @message.train_broadcast_before_to(@message, target: 'target', content: 'content')
    end
  end

  test "broadcast_after_to" do
    assert_broadcast_on @message, turbo_stream_action_tag("after", target: "target", template: 'content') do
      @message.train_broadcast_after_to(@message, target: 'target', content: 'content')
    end
  end

  test "broadcast_prepend_to" do
    assert_broadcast_on @message, turbo_stream_action_tag("prepend", target: "target", template: 'content') do
      @message.train_broadcast_prepend_to(@message, target: 'target', content: 'content')
    end
  end

  test "broadcast_prepend" do
    assert_broadcast_on @message, turbo_stream_action_tag("prepend", target: "target", template: 'content') do
      @message.train_broadcast_prepend(target: 'target', content: 'content')
    end
  end

  # later

  test "broadcast_replace_later_to" do
    assert_broadcast_on @message, turbo_stream_action_tag("replace", target: "target", template: 'content') do
      perform_enqueued_jobs do
        @message.train_broadcast_replace_later_to(@message, target: 'target', content: 'content')
      end
    end
  end

  test "broadcast_replace_later" do
    assert_broadcast_on @message, turbo_stream_action_tag("replace", target: "target", template: 'content') do
      perform_enqueued_jobs do
        @message.train_broadcast_replace_later(target: 'target', content: 'content')
      end
    end
  end

  test "broadcast_update_later_to" do
    assert_broadcast_on @message, turbo_stream_action_tag("update", target: "target", template: 'content') do
      perform_enqueued_jobs do
        @message.train_broadcast_update_later_to(@message, target: 'target', content: 'content')
      end
    end
  end

  test "broadcast_update_later" do
    assert_broadcast_on @message, turbo_stream_action_tag("update", target: "target", template: 'content') do
      perform_enqueued_jobs do
        @message.train_broadcast_update_later(target: 'target', content: 'content')
      end
    end
  end

  test "broadcast_append_later_to" do
    assert_broadcast_on @message, turbo_stream_action_tag("append", target: "target", template: 'content') do
      perform_enqueued_jobs do
        @message.train_broadcast_append_later_to(@message, target: 'target', content: 'content')
      end
    end
  end

  test "broadcast_append_later" do
    assert_broadcast_on @message, turbo_stream_action_tag("append", target: "target", template: 'content') do
      perform_enqueued_jobs do
        @message.train_broadcast_append_later(target: 'target', content: 'content')
      end
    end
  end

  test "broadcast_prepend_later_to" do
    assert_broadcast_on @message, turbo_stream_action_tag("prepend", target: "target", template: 'content') do
      perform_enqueued_jobs do
        @message.train_broadcast_prepend_later_to(@message, target: 'target', content: 'content')
      end
    end
  end

  test "broadcast_prepend_later" do
    assert_broadcast_on @message, turbo_stream_action_tag("prepend", target: "target", template: 'content') do
      perform_enqueued_jobs do
        @message.train_broadcast_prepend_later(target: 'target', content: 'content')
      end
    end
  end

  test "broadcast_action_later_to" do
    assert_broadcast_on @message, turbo_stream_action_tag("replace", target: "target", template: 'content') do
      perform_enqueued_jobs do
        @message.train_broadcast_action_later_to(@message, action: 'replace', target: 'target', content: 'content')
      end
    end
  end

  test "broadcast_action_later" do
    assert_broadcast_on @message, turbo_stream_action_tag("replace", target: "target", template: 'content') do
      perform_enqueued_jobs do
        @message.train_broadcast_action_later(action: 'replace', target: 'target', content: 'content')
      end
    end
  end

  test "train_broadcast_render_later_to" do
    assert_broadcast_on @message, turbo_stream_action_tag("replace", target: "message_1", template: "Goodbye!") do
      perform_enqueued_jobs do
        @message.train_broadcast_render_later_to(@message, partial: 'messages/message', locals: { message: @message })
      end
    end
  end

  test "train_broadcast_render_later" do
    assert_broadcast_on @message, turbo_stream_action_tag("replace", target: "message_1", template: "Goodbye!") do
      perform_enqueued_jobs do
        @message.train_broadcast_render_later(partial: 'messages/message', locals: { message: @message })
      end
    end
  end

end
