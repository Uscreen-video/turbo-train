# frozen_string_literal: true

class MessagesController < ApplicationController
  def index
    @messages = Message.all
  end
end
