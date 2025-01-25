class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ edit update destroy ]

  # 現在ログインしているユーザーのコメントレコードを取得する
  def show
    # 現在ログインしているユーザーのコメントレコードとそのコメント対象店舗のidを別々で取得する
    @comments = Comment.where(user_id: current_user.id)
    @shop_ids = Comment.where(user_id: current_user.id).pluck(:shop_id)

    # コメントしている店舗の情報をグルメサーチAPIで取得する
    api_client = HotpepperApiClient.new()
    @restaurants = api_client.search_restaurant_id(@shop_ids)
    @restaurants = @restaurants[:results][:shop]
  end

  # コメント編集
  def edit
  end

  # 送信されたパラメータを基にコメントレコードを作成して登録する
  def create
    @comment = Comment.new(comment_params)

    respond_to do |format|
      if @comment.save
        format.html { redirect_back fallback_location: restaurants_search_path, notice: "コメントが登録されました。" }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { redirect_back fallback_location: restaurants_search_path, notice: "コメントが正しく登録されませんでした。" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # 対象コメントレコードの内容を更新する
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to comment_path(current_user.id), flash: { comment_notice: "コメントが更新されました。" } }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # 対象コメントレコードを削除する
  def destroy
    @comment.destroy!

    respond_to do |format|
      format.html { redirect_back fallback_location: restaurants_search_path, status: :see_other, flash: { comment_notice: "コメントが削除されました。" } }
      format.json { head :no_content }
    end
  end

  private
    # パラメータのidを基に対象コメントレコードを取得する
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # コメントモデルのストロングパラメータ
    def comment_params
      params.require(:comment).permit(:user_id, :shop_id, :sentence)
    end
end
