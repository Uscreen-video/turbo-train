class MessagesController < ApplicationController
  def index
    @messages = Message.all
    @test_messages_id = ENV["TEST_MSG_ID"] || 'messages-local'
  end
end
