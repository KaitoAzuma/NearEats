require 'faraday' # HTTPクライアント
require 'json' # JSONレスポンスを解析するため

class HotpepperApiClient
  BASE_URL = 'http://webservice.recruit.co.jp/hotpepper/gourmet/v1/'

  # APIキーとFaradayの初期化
  def initialize()
    @api_key = ENV["HOTPEPPER_API_KEY"]
    @connection = Faraday.new(url: BASE_URL) do |conn|
      conn.request :url_encoded # URLエンコード形式でリクエストを送信
      conn.adapter Faraday.default_adapter # デフォルトのHTTPアダプター
    end
  end

  # 引数からパラメータ(緯度, 経度, 範囲, 取得数, オプション, 店舗名)を設定してHTTPリクエスト(GET)を送信
  def search_restaurants(lat, lng, range = 3, count = 50, options, name)
    response = @connection.get do |req|
      req.params[:key] = @api_key # APIキー
      req.params[:lat] = lat # 緯度
      req.params[:lng] = lng # 経度
      req.params[:range] = range # 検索範囲 (1〜5: 小さいほど狭い範囲)

      # optionsが存在した場合、含まれる文字列(パラメータ名)を参照し、そのパラメータの値を1に設定
      if options != 0
        options.each do |option|
          req.params[option.to_sym] = 1
        end
      end

      # 店舗名指定があった場合、掲載店名のパラメータを設定
      if name != ""
        req.params[:name] = name
      end

      req.params[:count] = count # 最大データ数
      req.params[:format] = 'json' # レスポンス形式
    end

    if response.success?
      parse_json(response.body)
    else
      Rails.logger.error("API Request failed: #{response.status} - #{response.body}")
      nil
    end
  rescue Faraday::ConnectionFailed => e
    Rails.logger.error("Connection failed: #{e.message}")
    nil
  end

  # 引数からパラメータ(idは配列でも単体の文字列でも可能)を設定してHTTPリクエスト(GET)を送信
  def search_restaurant_id(id)
    # idが配列であればカンマ区切りの文字列に変換、単体の文字列であればそのまま文字列にする
    id_param = id.is_a?(Array) ? id.join(',') : id.to_s

    response = @connection.get do |req|
      req.params[:key] = @api_key # APIキー
      req.params[:id] = id_param # お店id(単体もしくは複数)
      req.params[:format] = 'json' # レスポンス形式
    end

    if response.success?
      parse_json(response.body)
    else
      Rails.logger.error("API Request failed: #{response.status} - #{response.body}")
      nil
    end
  rescue Faraday::ConnectionFailed => e
    Rails.logger.error("Connection failed: #{e.message}")
    nil
  end

  private

  # JSONレスポンスをパース
  def parse_json(body)
    JSON.parse(body, symbolize_names: true)
  rescue JSON::ParserError => e
    Rails.logger.error("JSON Parsing failed: #{e.message}")
    nil
  end
end
