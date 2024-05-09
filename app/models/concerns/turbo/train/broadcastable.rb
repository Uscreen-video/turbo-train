# frozen_string_literal: true

# Based on: Turbo::Broadcastable
module Turbo
  module Train
    module Broadcastable
      extend ActiveSupport::Concern

      module ClassMethods
        # Configures the model to broadcast creates, updates, and destroys to a stream name derived at runtime by the
        # <tt>stream</tt> symbol invocation. By default, the creates are appended to a dom id target name derived from
        # the model's plural name. The insertion can also be made to be a prepend by overwriting <tt>inserts_by</tt> and
        # the target dom id overwritten by passing <tt>target</tt>. Examples:
        #
        #   class Message < ApplicationRecord
        #     belongs_to :board
        #     broadcasts_to :board
        #   end
        #
        #   class Message < ApplicationRecord
        #     belongs_to :board
        #     train_broadcasts_to ->(message) { [ message.board, :messages ] }, inserts_by: :prepend, target: "board_messages"
        #   end
        #
        #   class Message < ApplicationRecord
        #     belongs_to :board
        #     train_broadcasts_to ->(message) { [ message.board, :messages ] }, partial: "messages/custom_message"
        #   end
        def train_broadcasts_to(stream, inserts_by: :append, target: train_broadcast_target_default, **rendering)
          after_create_commit  lambda {
                                 train_broadcast_action_later_to(stream.try(:call, self) || send(stream), action: inserts_by,
                                                                                                          target: target.try(:call, self) || target, **rendering)
                               }
          after_update_commit  lambda {
                                 train_broadcast_replace_later_to(stream.try(:call, self) || send(stream), **rendering)
                               }
          after_destroy_commit -> { train_broadcast_remove_to(stream.try(:call, self) || send(stream)) }
        end

        # Same as <tt>#train_broadcasts_to</tt>, but the designated stream for updates and destroys is automatically set to
        # the current model, for creates - to the model plural name, which can be overriden by passing <tt>stream</tt>.
        def train_broadcasts(stream = model_name.plural, inserts_by: :append, target: train_broadcast_target_default,
                             **rendering)
          after_create_commit  lambda {
                                 train_broadcast_action_later_to(stream, action: inserts_by,
                                                                         target: target.try(:call, self) || target, **rendering)
                               }
          after_update_commit  -> { train_broadcast_replace_later(**rendering) }
          after_destroy_commit -> { train_broadcast_remove }
        end

        # All default targets will use the return of this method. Overwrite if you want something else than <tt>model_name.plural</tt>.
        def train_broadcast_target_default
          model_name.plural
        end
      end

      # Remove this broadcastable model from the dom for subscribers of the stream name identified by the passed streamables.
      # Example:
      #
      #   # Sends <turbo-stream action="remove" target="clearance_5"></turbo-stream> to the stream named "identity:2:clearances"
      #   clearance.train_broadcast_remove_to examiner.identity, :clearances
      def train_broadcast_remove_to(*streamables, target: self)
        Turbo::Train.broadcast_remove_to(*streamables, target:)
      end

      # Same as <tt>#train_broadcast_remove_to</tt>, but the designated stream is automatically set to the current model.
      def train_broadcast_remove
        train_broadcast_remove_to self
      end

      # Replace this broadcastable model in the dom for subscribers of the stream name identified by the passed
      # <tt>streamables</tt>. The rendering parameters can be set by appending named arguments to the call. Examples:
      #
      #   # Sends <turbo-stream action="replace" target="clearance_5"><template><div id="clearance_5">My Clearance</div></template></turbo-stream>
      #   # to the stream named "identity:2:clearances"
      #   clearance.train_broadcast_replace_to examiner.identity, :clearances
      #
      #   # Sends <turbo-stream action="replace" target="clearance_5"><template><div id="clearance_5">Other partial</div></template></turbo-stream>
      #   # to the stream named "identity:2:clearances"
      #   clearance.train_broadcast_replace_to examiner.identity, :clearances, partial: "clearances/other_partial", locals: { a: 1 }
      def train_broadcast_replace_to(*streamables, **rendering)
        Turbo::Train.broadcast_replace_to(*streamables, target: self,
                                                        **train_broadcast_rendering_with_defaults(rendering))
      end

      # Same as <tt>#train_broadcast_replace_to</tt>, but the designated stream is automatically set to the current model.
      def train_broadcast_replace(**rendering)
        train_broadcast_replace_to self, **rendering
      end

      # Update this broadcastable model in the dom for subscribers of the stream name identified by the passed
      # <tt>streamables</tt>. The rendering parameters can be set by appending named arguments to the call. Examples:
      #
      #   # Sends <turbo-stream action="update" target="clearance_5"><template><div id="clearance_5">My Clearance</div></template></turbo-stream>
      #   # to the stream named "identity:2:clearances"
      #   clearance.train_broadcast_update_to examiner.identity, :clearances
      #
      #   # Sends <turbo-stream action="update" target="clearance_5"><template><div id="clearance_5">Other partial</div></template></turbo-stream>
      #   # to the stream named "identity:2:clearances"
      #   clearance.train_broadcast_update_to examiner.identity, :clearances, partial: "clearances/other_partial", locals: { a: 1 }
      def train_broadcast_update_to(*streamables, **rendering)
        Turbo::Train.broadcast_update_to(*streamables, target: self,
                                                       **train_broadcast_rendering_with_defaults(rendering))
      end

      # Same as <tt>#broadcast_update_to</tt>, but the designated stream is automatically set to the current model.
      def train_broadcast_update(**rendering)
        train_broadcast_update_to self, **rendering
      end

      # Insert a rendering of this broadcastable model before the target identified by it's dom id passed as <tt>target</tt>
      # for subscribers of the stream name identified by the passed <tt>streamables</tt>. The rendering parameters can be set by
      # appending named arguments to the call. Examples:
      #
      #   # Sends <turbo-stream action="before" target="clearance_5"><template><div id="clearance_4">My Clearance</div></template></turbo-stream>
      #   # to the stream named "identity:2:clearances"
      #   clearance.train_broadcast_before_to examiner.identity, :clearances, target: "clearance_5"
      #
      #   # Sends <turbo-stream action="before" target="clearance_5"><template><div id="clearance_4">Other partial</div></template></turbo-stream>
      #   # to the stream named "identity:2:clearances"
      #   clearance.train_broadcast_before_to examiner.identity, :clearances, target: "clearance_5",
      #     partial: "clearances/other_partial", locals: { a: 1 }
      def train_broadcast_before_to(*streamables, target:, **rendering)
        Turbo::Train.broadcast_before_to(*streamables, target:, **train_broadcast_rendering_with_defaults(rendering))
      end

      # Insert a rendering of this broadcastable model after the target identified by it's dom id passed as <tt>target</tt>
      # for subscribers of the stream name identified by the passed <tt>streamables</tt>. The rendering parameters can be set by
      # appending named arguments to the call. Examples:
      #
      #   # Sends <turbo-stream action="after" target="clearance_5"><template><div id="clearance_6">My Clearance</div></template></turbo-stream>
      #   # to the stream named "identity:2:clearances"
      #   clearance.train_broadcast_after_to examiner.identity, :clearances, target: "clearance_5"
      #
      #   # Sends <turbo-stream action="after" target="clearance_5"><template><div id="clearance_6">Other partial</div></template></turbo-stream>
      #   # to the stream named "identity:2:clearances"
      #   clearance.train_broadcast_after_to examiner.identity, :clearances, target: "clearance_5",
      #     partial: "clearances/other_partial", locals: { a: 1 }
      def train_broadcast_after_to(*streamables, target:, **rendering)
        Turbo::Train.broadcast_after_to(*streamables, target:, **train_broadcast_rendering_with_defaults(rendering))
      end

      # Append a rendering of this broadcastable model to the target identified by it's dom id passed as <tt>target</tt>
      # for subscribers of the stream name identified by the passed <tt>streamables</tt>. The rendering parameters can be set by
      # appending named arguments to the call. Examples:
      #
      #   # Sends <turbo-stream action="append" target="clearances"><template><div id="clearance_5">My Clearance</div></template></turbo-stream>
      #   # to the stream named "identity:2:clearances"
      #   clearance.train_broadcast_append_to examiner.identity, :clearances, target: "clearances"
      #
      #   # Sends <turbo-stream action="append" target="clearances"><template><div id="clearance_5">Other partial</div></template></turbo-stream>
      #   # to the stream named "identity:2:clearances"
      #   clearance.train_broadcast_append_to examiner.identity, :clearances, target: "clearances",
      #     partial: "clearances/other_partial", locals: { a: 1 }
      def train_broadcast_append_to(*streamables, target: train_broadcast_target_default, **rendering)
        Turbo::Train.broadcast_append_to(*streamables, target:, **train_broadcast_rendering_with_defaults(rendering))
      end

      # Same as <tt>#train_broadcast_append_to</tt>, but the designated stream is automatically set to the current model.
      def train_broadcast_append(target: train_broadcast_target_default, **rendering)
        train_broadcast_append_to self, target:, **rendering
      end

      # Prepend a rendering of this broadcastable model to the target identified by it's dom id passed as <tt>target</tt>
      # for subscribers of the stream name identified by the passed <tt>streamables</tt>. The rendering parameters can be set by
      # appending named arguments to the call. Examples:
      #
      #   # Sends <turbo-stream action="prepend" target="clearances"><template><div id="clearance_5">My Clearance</div></template></turbo-stream>
      #   # to the stream named "identity:2:clearances"
      #   clearance.train_broadcast_prepend_to examiner.identity, :clearances, target: "clearances"
      #
      #   # Sends <turbo-stream action="prepend" target="clearances"><template><div id="clearance_5">Other partial</div></template></turbo-stream>
      #   # to the stream named "identity:2:clearances"
      #   clearance.train_broadcast_prepend_to examiner.identity, :clearances, target: "clearances",
      #     partial: "clearances/other_partial", locals: { a: 1 }
      def train_broadcast_prepend_to(*streamables, target: train_broadcast_target_default, **rendering)
        Turbo::Train.broadcast_prepend_to(*streamables, target:,
                                                        **train_broadcast_rendering_with_defaults(rendering))
      end

      # Same as <tt>#train_broadcast_prepend_to</tt>, but the designated stream is automatically set to the current model.
      def train_broadcast_prepend(target: train_broadcast_target_default, **rendering)
        train_broadcast_prepend_to self, target:, **rendering
      end

      # Broadcast a named <tt>action</tt>, allowing for dynamic dispatch, instead of using the concrete action methods. Examples:
      #
      #   # Sends <turbo-stream action="prepend" target="clearances"><template><div id="clearance_5">My Clearance</div></template></turbo-stream>
      #   # to the stream named "identity:2:clearances"
      #   clearance.train_broadcast_action_to examiner.identity, :clearances, action: :prepend, target: "clearances"
      def train_broadcast_action_to(*streamables, action:, target: train_broadcast_target_default, **rendering)
        Turbo::Train.broadcast_action_to(*streamables, action:, target:,
                                                       **train_broadcast_rendering_with_defaults(rendering))
      end

      # Same as <tt>#train_broadcast_action_to</tt>, but the designated stream is automatically set to the current model.
      def train_broadcast_action(action, target: train_broadcast_target_default, **rendering)
        train_broadcast_action_to self, action:, target:, **rendering
      end

      # Same as <tt>train_broadcast_replace_to</tt> but run asynchronously via a <tt>Turbo::Streams::BroadcastJob</tt>.
      def train_broadcast_replace_later_to(*streamables, **rendering)
        Turbo::Train.broadcast_replace_later_to(*streamables, target: self,
                                                              **train_broadcast_rendering_with_defaults(rendering))
      end

      # Same as <tt>#train_broadcast_replace_later_to</tt>, but the designated stream is automatically set to the current model.
      def train_broadcast_replace_later(**rendering)
        train_broadcast_replace_later_to self, **rendering
      end

      # Same as <tt>train_broadcast_update_to</tt> but run asynchronously via a <tt>Turbo::Streams::BroadcastJob</tt>.
      def train_broadcast_update_later_to(*streamables, **rendering)
        Turbo::Train.broadcast_update_later_to(*streamables, target: self,
                                                             **train_broadcast_rendering_with_defaults(rendering))
      end

      # Same as <tt>#train_broadcast_update_later_to</tt>, but the designated stream is automatically set to the current model.
      def train_broadcast_update_later(**rendering)
        train_broadcast_update_later_to self, **rendering
      end

      # Same as <tt>train_broadcast_append_to</tt> but run asynchronously via a <tt>Turbo::Streams::BroadcastJob</tt>.
      def train_broadcast_append_later_to(*streamables, target: train_broadcast_target_default, **rendering)
        Turbo::Train.broadcast_append_later_to(*streamables, target:,
                                                             **train_broadcast_rendering_with_defaults(rendering))
      end

      # Same as <tt>#train_broadcast_append_later_to</tt>, but the designated stream is automatically set to the current model.
      def train_broadcast_append_later(target: train_broadcast_target_default, **rendering)
        train_broadcast_append_later_to self, target:, **rendering
      end

      # Same as <tt>train_broadcast_prepend_to</tt> but run asynchronously via a <tt>Turbo::Streams::BroadcastJob</tt>.
      def train_broadcast_prepend_later_to(*streamables, target: train_broadcast_target_default, **rendering)
        Turbo::Train.broadcast_prepend_later_to(*streamables, target:,
                                                              **train_broadcast_rendering_with_defaults(rendering))
      end

      # Same as <tt>#train_broadcast_prepend_later_to</tt>, but the designated stream is automatically set to the current model.
      def train_broadcast_prepend_later(target: train_broadcast_target_default, **rendering)
        train_broadcast_prepend_later_to self, target:, **rendering
      end

      # Same as <tt>train_broadcast_action_to</tt> but run asynchronously via a <tt>Turbo::Streams::BroadcastJob</tt>.
      def train_broadcast_action_later_to(*streamables, action:, target: train_broadcast_target_default, **rendering)
        Turbo::Train.broadcast_action_later_to(*streamables, action:, target:,
                                                             **train_broadcast_rendering_with_defaults(rendering))
      end

      # Same as <tt>#train_broadcast_action_later_to</tt>, but the designated stream is automatically set to the current model.
      def train_broadcast_action_later(action:, target: train_broadcast_target_default, **rendering)
        train_broadcast_action_later_to self, action:, target:, **rendering
      end

      # Render a turbo stream template with this broadcastable model passed as the local variable. Example:
      #
      #   # Template: entries/_entry.turbo_stream.erb
      #   <%= turbo_stream.remove entry %>
      #
      #   <%= turbo_stream.append "entries", entry if entry.active? %>
      #
      # Sends:
      #
      #   <turbo-stream action="remove" target="entry_5"></turbo-stream>
      #   <turbo-stream action="append" target="entries"><template><div id="entry_5">My Entry</div></template></turbo-stream>
      #
      # ...to the stream named "entry:5".
      #
      # Note that rendering inline via this method will cause template rendering to happen synchronously. That is usually not
      # desireable for model callbacks, certainly not if those callbacks are inside of a transaction. Most of the time you should
      # be using `train_broadcast_render_later`, unless you specifically know why synchronous rendering is needed.
      def train_broadcast_render(**rendering)
        train_broadcast_render_to self, **rendering
      end

      # Same as <tt>train_broadcast_render</tt> but run with the added option of naming the stream using the passed
      # <tt>streamables</tt>.
      #
      # Note that rendering inline via this method will cause template rendering to happen synchronously. That is usually not
      # desireable for model callbacks, certainly not if those callbacks are inside of a transaction. Most of the time you should
      # be using `train_broadcast_render_later_to`, unless you specifically know why synchronous rendering is needed.
      def train_broadcast_render_to(*streamables, **rendering)
        Turbo::Train.broadcast_render_to(*streamables, **train_broadcast_rendering_with_defaults(rendering))
      end

      # Same as <tt>train_broadcast_action_to</tt> but run asynchronously via a <tt>Turbo::Streams::BroadcastJob</tt>.
      def train_broadcast_render_later(**rendering)
        train_broadcast_render_later_to self, **rendering
      end

      # Same as <tt>train_broadcast_render_later</tt> but run with the added option of naming the stream using the passed
      # <tt>streamables</tt>.
      def train_broadcast_render_later_to(*streamables, **rendering)
        Turbo::Train.broadcast_render_later_to(*streamables, **train_broadcast_rendering_with_defaults(rendering))
      end

      private

      def train_broadcast_target_default
        self.class.train_broadcast_target_default
      end

      def train_broadcast_rendering_with_defaults(options)
        options.tap do |o|
          # Add the current instance into the locals with the element name (which is the un-namespaced name)
          # as the key. This parallels how the ActionView::ObjectRenderer would create a local variable.
          o[:locals] = (o[:locals] || {}).reverse_merge!(model_name.element.to_sym => self)

          if o[:html] || o[:partial]
            return o
          elsif o[:template]
            o[:layout] = false
          else
            # if none of these options are passed in, it will set a partial from #to_partial_path
            o[:partial] ||= to_partial_path
          end
        end
      end
    end
  end
end
