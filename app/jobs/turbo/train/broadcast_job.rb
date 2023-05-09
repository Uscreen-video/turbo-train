module Turbo
  module Train
    class BroadcastJob < ActiveJob::Base
      discard_on ActiveJob::DeserializationError

      def perform(stream, **rendering)
        Turbo::Train.broadcast_render_to(stream, **rendering)
      end
    end
  end
end
