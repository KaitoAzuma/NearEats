class CommentsController < ApplicationController
  before_action :set_comment, only: %i[ edit update destroy ]

  # GET /comments or /comments.json
  def index
    @comments = Comment.all
  end

  # GET /comments/1 or /comments/1.json
  def show
    @comments = Comment.where(user_id: current_user.id)
    @shop_ids = Comment.where(user_id: current_user.id).pluck(:shop_id)

    api_client = HotpepperApiClient.new()
    @restaurants = api_client.search_restaurant_id(@shop_ids)
    @restaurants = @restaurants[:results][:shop]
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments or /comments.json
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

  # PATCH/PUT /comments/1 or /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to comment_path(current_user.id), notice: "コメントが更新されました。" }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1 or /comments/1.json
  def destroy
    @comment.destroy!

    respond_to do |format|
      format.html { redirect_back fallback_location: restaurants_search_path, status: :see_other, notice: "コメントが削除されました。" }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def comment_params
      params.require(:comment).permit(:user_id, :shop_id, :sentence)
    end
end
