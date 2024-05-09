# frozen_string_literal: true

require 'turbo-rails'

module Turbo
  module Train
    class Engine < ::Rails::Engine
      isolate_namespace Turbo::Train
      config.autoload_once_paths = %W[
        #{root}/app/channels
        #{root}/app/controllers
        #{root}/app/controllers/concerns
        #{root}/app/helpers
        #{root}/app/models
        #{root}/app/models/concerns
        #{root}/app/jobs
      ]

      PRECOMPILE_ASSETS = %w[turbo-train.js turbo-train.min.js].freeze

      initializer 'turbotrain.assets' do
        Rails.application.config.assets.precompile += PRECOMPILE_ASSETS if Rails.application.config.respond_to?(:assets)
      end

      initializer 'turbotrain.helpers', before: :load_config_initializers do
        ActiveSupport.on_load(:action_controller_base) do
          helper Turbo::Train::StreamsHelper
        end
      end

      initializer 'turbotrain.load' do
        ActiveSupport.on_load(:active_record) do
          require_relative 'train'
        end
      end
    end
  end
end
