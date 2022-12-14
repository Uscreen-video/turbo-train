require 'turbo-rails'

module Turbo
  module Train
    class Engine < ::Rails::Engine
      isolate_namespace Turbo::Train

      PRECOMPILE_ASSETS = %w( turbo-train.js turbo-train.min.js )

      initializer "turbotrain.assets" do
        if Rails.application.config.respond_to?(:assets)
          Rails.application.config.assets.precompile += PRECOMPILE_ASSETS
        end
      end

      initializer "turbotrain.helpers", before: :load_config_initializers do
        ActiveSupport.on_load(:action_controller_base) do
          helper Turbo::Train::StreamsHelper
        end
      end

      initializer "turbotrain.load" do
        ActiveSupport.on_load(:active_record) do
          require_relative 'train'
        end
      end
    end
  end
end
