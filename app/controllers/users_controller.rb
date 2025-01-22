class UsersController < ApplicationController
  before_action :set_user, only: %i[ update ]

  def update
    if @user.update(user_params)
      redirect_to restaurants_search_path
    else
      redirect_back fallback_location: restaurants_search_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:name)
    end
end
