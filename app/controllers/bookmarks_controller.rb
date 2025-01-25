class BookmarksController < ApplicationController

  # 現在ログインしているユーザーのブックマークレコードを参照して対応する店舗情報を取得する
  def index
    # ユーザーがログインしていれば、処理を行う
    if user_signed_in?
      # 現在ログインしているユーザーのブックマークレコードとそのブックマーク対象店舗のidを別々で取得する
      @bookmarks = Bookmark.where(user_id: current_user.id)
      @shop_ids = @bookmarks.pluck(:shop_id)

      # ページング用パラメータ
      page = params[:page] || 1
      per_page = 10

      # グルメサーチAPIへHTTPリクエストを送信して、レスポンスを取得する
      api_client = HotpepperApiClient.new()
      @restaurants_all = api_client.search_restaurant_id(@shop_ids)

      # ページング処理
      @restaurants = Kaminari.paginate_array(Array(@restaurants_all[:results][:shop])).page(page).per(per_page)
      @current_shops_count = @restaurants.size
      @total_shops_count = @restaurants_all[:results][:results_returned]
      @start = (page.to_i - 1) * per_page + 1
    end
  end

  # 単体の店舗情報を取得し直す
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

  # 現在ログインしているユーザーのブックマークレコードを登録する
  def create
    # 現在ログインしているユーザーのブックマークレコードの数を取得する
    @bookmarks_count = Bookmark.where(user_id: current_user.id).count

    # レコード数が19件以下だったら登録処理を行う (=>ユーザー1人が登録できるブックマークは20件まで)
    if @bookmarks_count <= 19
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
    else
      redirect_back fallback_location: restaurants_search_path, flash: { bm_max: "登録できるブックマークは20件までです。" }
    end
  end

  # 対象ブックマークレコードを削除する
  def destroy
    # パラメータにshop_idが存在する場合、現在ログインしているユーザーの対象店舗に対するブックマークレコードを削除する
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

end
