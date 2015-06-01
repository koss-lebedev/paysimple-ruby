require 'time'
require 'digest'
require 'base64'

require 'rest-client'
require 'json'

# Common
require 'paysimple/version'
require 'paysimple/endpoint'
require 'paysimple/util'

# Enumerations
require 'paysimple/enumerations/issuer'
require 'paysimple/enumerations/payment_type'
require 'paysimple/enumerations/payment_sub_type'
require 'paysimple/enumerations/schedule_status'
require 'paysimple/enumerations/payment_status'
require 'paysimple/enumerations/execution_frequency_type'

# Resources
require 'paysimple/resources/customer'
require 'paysimple/resources/credit_card'
require 'paysimple/resources/ach'
require 'paysimple/resources/payment'
require 'paysimple/resources/recurring_payment'
require 'paysimple/resources/payment_plan'

# Errors
require 'paysimple/errors/paysimple_error'
require 'paysimple/errors/api_connection_error'
require 'paysimple/errors/api_error'
require 'paysimple/errors/invalid_request_error'
require 'paysimple/errors/authentication_error'

module Paysimple

  @api_endpoint = Endpoint::PRODUCTION

  class << self
    attr_accessor :api_key, :api_user, :api_endpoint
  end

  def self.request(method, url, params={})

    raise AuthenticationError.new('API key is not provided.') unless @api_key
    raise AuthenticationError.new('API user is not provided.') unless @api_user

    url = api_url(url)
    case method
      when :get, :head
        url += "#{URI.parse(url).query ? '&' : '?'}#{uri_encode(params)}" if params && params.any?
        payload = nil
      when :delete
        payload = nil
      else
        payload = Util.camelize_and_symbolize_keys(params).to_json
    end

    request_opts = { headers: request_headers, method: method, open_timeout: 30,
                     payload: payload, url: url, timeout: 80 }

    begin
      response = execute_request(request_opts)
    rescue SocketError => e
      handle_restclient_error(e)
    rescue RestClient::ExceptionWithResponse => e
      if rcode = e.http_code and rbody = e.http_body
        handle_api_error(rcode, rbody)
      else
        handle_restclient_error(e)
      end
    rescue RestClient::Exception, Errno::ECONNREFUSED => e
      handle_restclient_error(e)
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
    if response.body.empty?
      {}
    else
      response = JSON.parse(response.body)
      Util.underscore_and_symbolize_names(response)[:response]
    end
  rescue JSON::ParserError
    raise general_api_error(response.code, response.body)
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

  def self.handle_api_error(rcode, rbody)
    begin
      error_obj = rbody.empty? ? {} : Util.underscore_and_symbolize_names(JSON.parse(rbody))
    rescue JSON::ParserError
      raise general_api_error(rcode, rbody)
    end

    case rcode
      when 400, 404
        errors = error_obj[:meta][:errors][:error_messages].collect { |e| e[:message]}
        raise InvalidRequestError.new(errors, rcode, rbody, error_obj)
      when 401
        raise  AuthenticationError.new(error, rcode, rbody, error_obj)
      else
        raise APIError.new(error, rcode, rbody, error_obj)
    end
  end

  def self.handle_restclient_error(e, api_base_url=nil)
    connection_message = 'Please check your internet connection and try again.'

    case e
      when RestClient::RequestTimeout
        message = "Could not connect to Paysimple (#{@api_endpoint}). #{connection_message}"
      when RestClient::ServerBrokeConnection
        message = "The connection to the server (#{@api_endpoint}) broke before the " \
        "request completed. #{connection_message}"
      when SocketError
        message = 'Unexpected error communicating when trying to connect to Paysimple. ' \
        'You may be seeing this message because your DNS is not working. '
      else
        message = 'Unexpected error communicating with Paysimple. '
    end

    raise APIConnectionError.new(message + "\n\n(Network error: #{e.message})")
  end

end