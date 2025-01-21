class RestaurantsController < ApplicationController

  def search

  end

  def result
    # 前ページから送信されたフォーム内容より、グルメサーチAPIへのリクエスト送信に必要なパラメータを設定する
    lat = params[:latitude].to_f
    lng = params[:longitude].to_f
    range = params[:range].to_i
    if params[:option].present?
      options = params[:option]
    else
      options = 0
    end
    name = params[:name]
    count = 50

    # ページング用パラメータ
    page = params[:page] || 1
    per_page = 10

    # グルメサーチAPIへHTTPリクエストを送信して、レスポンスを取得する
    if lat.present? && lng.present?
      api_client = HotpepperApiClient.new()
      @restaurants_all = api_client.search_restaurants(lat, lng, range, count, options, name)

      # ページング処理
      @restaurants = Kaminari.paginate_array(@restaurants_all[:results][:shop]).page(page).per(per_page)
      @current_shops_count = @restaurants.size
      @total_shops_count = @restaurants_all[:results][:results_returned]
      @start = (page.to_i - 1) * per_page + 1
    else
      # 緯度経度が正しく取得できなかった場合のエラー処理
      @restaurants = nil
      flash[:alert] = "現在地情報が不足しています。緯度と経度を指定してください。"
    end
  end

  def show
    # パラメータで指定したidを基に単体の店舗情報を取得し直す
    api_client = HotpepperApiClient.new()
    @restaurant = api_client.search_restaurant_id(params[:id])
    if @restaurant.nil? || @restaurant[:results][:shop].empty?
      flash[:alert] = "レストラン情報が見つかりませんでした。"
    end
    @shop_detail = @restaurant[:results][:shop][0]
    @result_url = params[:result_url] || restaurants_search_path
  end

  def ex
    redirect_back(fallback_location: restaurants_search_path)
  end
end
