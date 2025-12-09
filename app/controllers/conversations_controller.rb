# frozen_string_literal: true

class ConversationsController < ApplicationController
  before_action :set_conversation, only: [ :show ]

  def index
    @page_title = "Messages"
    @conversations = current_user_conversations
                      .includes(:participant_one, :participant_two, :messages)
                      .order(last_message_at: :desc)
    render Views::Conversations::Index.new(
      conversations: @conversations,
      current_user: Current.user
    ), layout: phlex_layout
  end

  def show
    @messages = @conversation.messages.includes(:sender).order(created_at: :asc)
    @other_participant = other_participant(@conversation)

    # Mark messages as read
    @conversation.messages
                 .where.not(sender: Current.user)
                 .where(read: false)
                 .update_all(read: true, read_at: Time.current)

    @page_title = @other_participant.display_name
    render Views::Conversations::Show.new(
      conversation: @conversation,
      messages: @messages,
      other_participant: @other_participant,
      current_user: Current.user
    ), layout: phlex_layout
  end

  def create
    other_user = User.find(params[:user_id])

    @conversation = find_or_create_conversation(other_user)

    redirect_to conversation_path(@conversation)
  end

  private

  def set_conversation
    @conversation = current_user_conversations.find(params[:id])
  end

  def current_user_conversations
    Conversation.where(participant_one: Current.user)
                .or(Conversation.where(participant_two: Current.user))
                .where(active: true)
  end

  def other_participant(conversation)
    if conversation.participant_one_id == Current.user.id
      conversation.participant_two
    else
      conversation.participant_one
    end
  end

  def find_or_create_conversation(other_user)
    # Find existing conversation
    existing = Conversation.where(participant_one: Current.user, participant_two: other_user)
                           .or(Conversation.where(participant_one: other_user, participant_two: Current.user))
                           .first

    return existing if existing

    # Create new conversation
    Conversation.create!(
      participant_one: Current.user,
      participant_two: other_user,
      job_request_id: params[:job_request_id]
    )
  end
end
