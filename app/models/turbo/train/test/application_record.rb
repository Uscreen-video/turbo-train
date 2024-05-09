# frozen_string_literal: true

module Turbo
  module Train
    module Test
      class ApplicationRecord < ActiveRecord::Base
        self.abstract_class = true
      end
    end
  end
end
