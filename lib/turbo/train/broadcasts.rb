module Turbo::Train::Broadcasts
  def broadcast(streamables, content:)
    topics = if streamables.is_a?(Array)
               streamables.map { |s| signed_stream_name(s) }
             else
               [signed_stream_name(streamables)]
             end

    data = {
      topic: topics,
      data: content
    }

    Turbo::Train.server.publish(topics: topics, data: data)
  end

  def broadcast_action_to(*streamables, action:, target: nil, targets: nil, **rendering)
    broadcast(streamables, content: turbo_stream_action_tag(action, target: target, targets: targets, template:
      rendering.delete(:content) || rendering.delete(:html) || (rendering.any? ? render_format(:html, **rendering) : nil)
    ))
  end

  def broadcast_render_to(*streamables, **rendering)
    broadcast(*streamables, content: render_format(:turbo_stream, **rendering))
  end

  def broadcast_remove_to(*streamables, **opts)
    broadcast_action_to(*streamables, action: :remove, **opts)
  end

  def broadcast_replace_to(*streamables, **opts)
    broadcast_action_to(*streamables, action: :replace, **opts)
  end

  def broadcast_update_to(*streamables, **opts)
    broadcast_action_to(*streamables, action: :update, **opts)
  end

  def broadcast_before_to(*streamables, **opts)
    broadcast_action_to(*streamables, action: :before, **opts)
  end

  def broadcast_after_to(*streamables, **opts)
    broadcast_action_to(*streamables, action: :after, **opts)
  end

  def broadcast_append_to(*streamables, **opts)
    broadcast_action_to(*streamables, action: :append, **opts)
  end

  def broadcast_prepend_to(*streamables, **opts)
    broadcast_action_to(*streamables, action: :prepend, **opts)
  end

  # later
  def broadcast_action_later_to(*streamables, action:, target: nil, targets: nil, **rendering)
    Turbo::Train::ActionBroadcastJob.perform_later streamables, action: action, target: target, targets: targets, **rendering
  end

  def broadcast_replace_later_to(*streamables, **opts)
    broadcast_action_later_to(*streamables, action: :replace, **opts)
  end

  def broadcast_remove_later_to(*streamables, **opts)
    broadcast_action_later_to(*streamables, action: :remove, **opts)
  end

  def broadcast_update_later_to(*streamables, **opts)
    broadcast_action_later_to(*streamables, action: :update, **opts)
  end

  def broadcast_before_later_to(*streamables, **opts)
    broadcast_action_later_to(*streamables, action: :before, **opts)
  end

  def broadcast_after_later_to(*streamables, **opts)
    broadcast_action_later_to(*streamables, action: :after, **opts)
  end

  def broadcast_append_later_to(*streamables, **opts)
    broadcast_action_later_to(*streamables, action: :append, **opts)
  end

  def broadcast_prepend_later_to(*streamables, **opts)
    broadcast_action_later_to(*streamables, action: :prepend, **opts)
  end

  def broadcast_render_later_to(*streamables, **rendering)
    Turbo::Train::BroadcastJob.perform_later streamables, **rendering
  end
end