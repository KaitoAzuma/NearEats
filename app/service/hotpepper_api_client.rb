require 'faraday' # HTTPクライアント
require 'json' # JSONレスポンスを解析するため

class HotpepperApiClient
  BASE_URL = 'http://webservice.recruit.co.jp/hotpepper/gourmet/v1/'

  # APIキーとFaradayの初期化
  def initialize()
    @api_key = "dfc525ce7760c49b"
    @connection = Faraday.new(url: BASE_URL) do |conn|
      conn.request :url_encoded # URLエンコード形式でリクエストを送信
      conn.adapter Faraday.default_adapter # デフォルトのHTTPアダプター
    end
  end

  def search_restaurants(lat, lng, range = 3)
    response = @connection.get do |req|
      req.params[:key] = @api_key
      req.params[:lat] = lat
      req.params[:lng] = lng
      req.params[:range] = range # 検索範囲 (1〜5: 小さいほど狭い範囲)
      req.params[:format] = 'json'
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
