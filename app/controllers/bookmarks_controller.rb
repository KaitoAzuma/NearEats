class BookmarksController < ApplicationController
  before_action :set_bookmark, only: %i[ edit update ]

  # GET /bookmarks or /bookmarks.json
  def index
    if user_signed_in?
      @bookmarks = Bookmark.where(user_id: current_user.id)
      @shop_ids = @bookmarks.pluck(:shop_id)

      # ページング用パラメータ
      page = params[:page] || 1
      per_page = 10

      api_client = HotpepperApiClient.new()
      @restaurants_all = api_client.search_restaurant_id(@shop_ids)

      # ページング処理
      @restaurants = Kaminari.paginate_array(Array(@restaurants_all[:results][:shop])).page(page).per(per_page)
      @current_shops_count = @restaurants.size
      @total_shops_count = @restaurants_all[:results][:results_returned]
      @start = (page.to_i - 1) * per_page + 1
    end
  end

  # GET /bookmarks/1 or /bookmarks/1.json
  def show
    # 参照する店舗のidを設定
    @shop_id = params[:id]

    # 店舗のidを基に単体の店舗情報を取得し直す
    api_client = HotpepperApiClient.new()
    @restaurant = api_client.search_restaurant_id(@shop_id)
    if @restaurant.nil? || @restaurant[:results][:shop].empty?
      flash[:alert] = "レストラン情報が見つかりませんでした。"
    end
    @shop_detail = @restaurant[:results][:shop][0]
    @result_url = params[:result_url] || restaurants_search_path

    # 参照する店舗に対するコメントを取得
    @comments = Comment.where(shop_id: @shop_id)

    # ユーザーがログインしている場合、新しいコメントインスタンスの作成とブックマーク判定を行う
    if user_signed_in?
      @new_comment = Comment.new
      @isBookmarked = Bookmark.exists?(user_id: current_user.id, shop_id: @shop_id)
    end
  end

  # GET /bookmarks/new
  def new
    @bookmark = Bookmark.new
  end

  # GET /bookmarks/1/edit
  def edit
  end

  # POST /bookmarks or /bookmarks.json
  def create
    @bookmark = Bookmark.new(user_id: current_user.id, shop_id: params[:shop_id])

    respond_to do |format|
      if @bookmark.save
        format.html { redirect_back fallback_location: restaurants_search_path }
        format.json { render :show, status: :created, location: @bookmark }
      else
        format.html { redirect_back fallback_location: restaurants_search_path }
        format.json { render json: @bookmark.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bookmarks/1 or /bookmarks/1.json
  def update
    respond_to do |format|
      if @bookmark.update(bookmark_params)
        format.html { redirect_to @bookmark, notice: "Bookmark was successfully updated." }
        format.json { render :show, status: :ok, location: @bookmark }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @bookmark.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookmarks/1 or /bookmarks/1.json
  def destroy
    if params[:shop_id].present?
      @bookmark = Bookmark.find_by(user_id: current_user.id, shop_id: params[:shop_id])
      if @bookmark
        @bookmark.destroy!
      end
    end

    respond_to do |format|
      format.html { redirect_back fallback_location: restaurants_search_path, status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bookmark
      @bookmark = Bookmark.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def bookmark_params
      params.require(:bookmark).permit(:user_id, :shop_id)
    end
end
