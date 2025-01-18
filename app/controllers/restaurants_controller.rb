class RestaurantsController < ApplicationController

  def search

  end

  def result
    # 前ページから送信されたフォーム内容より、グルメサーチAPIへのリクエスト送信に必要なパラメータを設定する
    lat = params[:latitude].to_f
    lng = params[:longitude].to_f
    range = params[:range].to_i
    options = params[:option].select { |value| value != "0" }
    name = params[:name]
    count = 50

    # グルメサーチAPIへHTTPリクエストを送信して、レスポンスを取得する
    if lat.present? && lng.present?
      api_client = HotpepperApiClient.new()
      @restaurants = api_client.search_restaurants(lat, lng, range, count, options, name)
    else
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
  end
end
