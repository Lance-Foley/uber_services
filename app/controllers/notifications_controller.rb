# frozen_string_literal: true

class NotificationsController < ApplicationController
  def index
    @page_title = "Notifications"
    @notifications = Current.user.notifications.order(created_at: :desc)
    render Views::Notifications::Index.new(notifications: @notifications), layout: phlex_layout
  end

  def mark_read
    @notification = Current.user.notifications.find(params[:id])
    @notification.update(read: true, read_at: Time.current)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notifications_path }
    end
  end

  def mark_all_read
    Current.user.notifications.where(read: false).update_all(read: true, read_at: Time.current)
    redirect_to notifications_path, notice: "All notifications marked as read."
  end
end
