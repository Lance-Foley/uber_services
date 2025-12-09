# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :set_conversation

  def create
    @message = @conversation.messages.build(message_params)
    @message.sender = Current.user

    if @message.save
      @conversation.touch(:last_message_at)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to conversation_path(@conversation) }
      end
    else
      redirect_to conversation_path(@conversation), alert: "Could not send message."
    end
  end

  private

  def set_conversation
    @conversation = current_user_conversations.find(params[:conversation_id])
  end

  def current_user_conversations
    Conversation.where(participant_one: Current.user)
                .or(Conversation.where(participant_two: Current.user))
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
