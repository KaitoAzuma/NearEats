class UsersController < ApplicationController

  # userのdevise関連以外のカラムを更新する
  def update
    # 現在ログインしているユーザーのレコードを取得して更新
    @user = User.find(current_user.id)

    if @user.update(name: params[:name])
      redirect_to restaurants_search_path
    else
      redirect_back fallback_location: restaurants_search_path
    end
  end

end
