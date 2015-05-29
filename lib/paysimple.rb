require 'time'
require 'digest'
require 'base64'

require 'rest-client'
require 'json'

# Common
require 'paysimple/version'
require 'paysimple/endpoint'
require 'paysimple/util'

# Resources
require 'paysimple/resources/customer'

# Errors
require 'paysimple/errors/paysimple_error'
require 'paysimple/errors/api_error'

module Paysimple

  @api_endpoint = Endpoint::PRODUCTION

  class << self
    attr_accessor :api_key, :api_user, :api_endpoint
  end

  def self.request(method, url, params={})

    url = api_url(url)
    case method
      when :get, :head, :delete
        url += "#{URI.parse(url).query ? '&' : '?'}#{uri_encode(params)}" if params && params.any?
        payload = nil
      else
        payload = params.to_json
    end

    request_opts = { headers: request_headers, method: method, open_timeout: 30,
                     payload: payload, url: url, timeout: 80 }

    begin
      response = execute_request(request_opts)
      # TODO: handle network errors
    end

    parse(response)
  end

  def self.api_url(url='')
    @api_endpoint + '/v4' + url
  end

  def self.execute_request(opts)
    RestClient::Request.execute(opts)
  end

  def self.request_headers
    {
        authorization: authorization_header,
        content_type: :json,
        accept: :json
    }
  end

  def self.uri_encode(params)
    Util.flatten_params(params).map { |k,v| "#{k}=#{Util.url_encode(v)}" }.join('&')
  end

  def self.parse(response)
    begin
      response = JSON.parse(response.body)
    rescue JSON::ParserError
      raise general_api_error(response.code, response.body)
    end

    # TODO: inspect response for errors in metas
    Util.symbolize_names(response)[:response]
  end

  def self.general_api_error(rcode, rbody)
    APIError.new("Invalid response object from API: #{rbody.inspect} " +
                     "(HTTP response code was #{rcode})", rcode, rbody)
  end

  def self.authorization_header
    utc_timestamp = Time.now.getutc.iso8601.encode(Encoding::UTF_8)
    secret_key = @api_key.encode(Encoding::UTF_8)
    hash = OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha256'), secret_key, utc_timestamp)
    signature = Base64.encode64(hash)

    "PSSERVER accessid=#{@api_user}; timestamp=#{utc_timestamp}; signature=#{signature}"
  end

end