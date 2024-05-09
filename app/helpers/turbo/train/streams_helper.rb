# frozen_string_literal: true

module Turbo
  module Train
    module StreamsHelper
      def turbo_train_from(*streamables, **attributes)
        attributes[:href] = Turbo::Train.server(attributes[:server]&.to_sym).listen_url(streamables, platform: 'web')
        tag.turbo_train_stream_source(**attributes)
      end
    end
  end
end
