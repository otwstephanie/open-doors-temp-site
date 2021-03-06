# encoding: utf-8
require 'net/http'
require 'logger'

module OtwArchive
  class HttpClient
    include Faraday

    API_PATH = "api/v1"

    def initialize(host_url, token, api_path = API_PATH)
      base_uri = "#{host_url}/#{api_path}"
      Rails.logger.info base_uri
      @conn = Faraday.new(base_uri, headers: { accept: "application/json" }) do |conn|
        conn.authorization :Token, token: token
        conn.headers["Content-Type"] = "application/json"

        conn.options[:open_timeout] = 2000
        conn.options[:timeout] = 1_200_000 # 20 minutes
        conn.request :json

        conn.response :json, content_type: /\bjson$/

        conn.use FaradayMiddleware::FollowRedirects
        conn.adapter Faraday.default_adapter
      end
    end

    def post_request(path, request = {})
      Rails.logger.info "\n----------post_request----------\n"
      Rails.logger.info "\n>>Request in post_request as_json:"
      Rails.logger.info JSON.pretty_generate(request.as_json)
      Rails.logger.info "\n----------END post_request----------"

      begin
        response = @conn.post path, request.to_json

        Rails.logger.info "\n----------raw response----------"
        Rails.logger.info response.status
        Rails.logger.info response.headers
        Rails.logger.info JSON.pretty_generate(response.body.as_json) unless response.body.nil?
        response.body
      rescue ConnectionFailed => e
        puts e.inspect
        { status: :error,
          messages: [e.message] }
      rescue StandardError => e
        puts e.inspect
        { status: :error,
          messages: [e.message] }
      end
    end
  end # HttpClient
end # OtwArchive

