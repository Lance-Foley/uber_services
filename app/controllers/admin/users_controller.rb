# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    before_action :set_user, only: [ :show, :edit, :update ]

    def index
      @users = User.order(created_at: :desc)
      @users = @users.where("email_address ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ?",
                            "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
      @users = @users.where(admin: true) if params[:admin] == "true"
      @users = @users.where(active: params[:active] == "true") if params[:active].present?
    end

    def show
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: "User updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email_address, :phone_number, :active, :admin)
    end
  end
end
