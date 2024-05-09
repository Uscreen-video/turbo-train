# frozen_string_literal: true

module Turbo
  module Train
    class ActionBroadcastJob < ActiveJob::Base
      discard_on ActiveJob::DeserializationError

      def perform(stream, action:, target:, **rendering)
        Turbo::Train.broadcast_action_to(
          stream,
          action:,
          target:,
          **rendering
        )
      end
    end
  end
end
