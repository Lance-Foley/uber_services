# frozen_string_literal: true

class ProfilesController < ApplicationController
  def show
    @page_title = "Profile"
    render Views::Profiles::Show.new(user: Current.user), layout: phlex_layout
  end

  def edit
    @page_title = "Edit Profile"
    render Views::Profiles::Edit.new(user: Current.user), layout: phlex_layout
  end

  def update
    @user = Current.user

    if @user.update(user_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      @page_title = "Edit Profile"
      render Views::Profiles::Edit.new(user: @user), layout: phlex_layout, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :phone_number, :avatar_url)
  end
end
