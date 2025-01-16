class RestaurantsController < ApplicationController

  def search

  end

  def result
    lat = 34.897349492731884
    lng = 132.07218445966453
    range = 5

    if lat.present? && lng.present?
      api_client = HotpepperApiClient.new()
      @restaurants = api_client.search_restaurants(lat, lng, range)

      if @restaurants.nil? || @restaurants[:results][:shop].empty?
        flash[:alert] = "レストラン情報が見つかりませんでした。"
      end
    else
      @restaurants = nil
      flash[:alert] = "現在地情報が不足しています。緯度と経度を指定してください。"
    end
  end
end
