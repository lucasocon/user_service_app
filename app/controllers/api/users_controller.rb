class Api::UsersController < ApplicationController
  # GET /users
  def index
    @users = User.search_by(search_params)
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render :show, status: :created
    else
      render json: { errors:  @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.fetch(:user, {}).permit(:email, :phone_number, :full_name,
                                   :password, :metadata)
  end

  def search_params
    params.fetch(:query, {}).permit(:email, :full_name, :metadata)
  end
end
