require 'restclient'
require 'multi_json'

class Gemical::Connection
  include Gemical::Singleton

  HTTPError        = Class.new(StandardError)
  HTTPUnauthorized = Class.new(HTTPError)
  HTTPServerError  = Class.new(HTTPError)
  HTTPNotFound     = Class.new(HTTPError)

  class HTTPUnprocessable < HTTPError

    attr_reader :response

    def initialize(response)
      @response = response
      super "Unprocessable Entity (422)"
    end

  end

  attr_accessor :base_url

  def initialize
    @base_url  = ENV['GEMICAL_URL'] || "http://api.gemical.com"
    self.proxy = ENV['http_proxy']
  end

  def proxy
    RestClient.proxy
  end

  def proxy=(url)
    RestClient.proxy = url if url
  end

  def get(path, options = {})
    request :get, path, build_headers(options)
  end

  def post(path, options = {})
    request :post, path, options.delete(:params), build_headers(options)
  end

  def delete(path, options = {})
    request :delete, path, build_headers(options)
  end

  protected

    def request(method, path, *args)
      url = [base_url, path].join
      MultiJson.decode RestClient.send(method, url, *args)
    rescue SocketError, Errno::ECONNREFUSED, Errno::ETIMEDOUT
      say_error "Ooops. Can't establish a connection to #{base_url}. Are you on-line?"
      exit(1)
    rescue RestClient::UnprocessableEntity => e
      raise HTTPUnprocessable.new MultiJson.decode(e.response.body)
    rescue RestClient::Unauthorized, RestClient::Forbidden => e
      raise HTTPUnauthorized, "Unauthorized request (#{e.http_code})"
    rescue RestClient::ResourceNotFound
      raise HTTPNotFound, "Resource not found (404)"
    rescue RestClient::Exception => e
      raise HTTPServerError, "Service responded with #{e.to_s}"
    end

    def build_headers(options)
      { :accept => :json }.merge(authorization(options)).merge(options.delete(:headers) || {})
    end

    def authorization(options)
      pair  = options.delete(:basic_auth) || Gemical.auth.basic_auth
      token = [pair.join(':')].pack("m").delete("\r\n")
      { :authorization => "Basic #{token}" }
    end

end