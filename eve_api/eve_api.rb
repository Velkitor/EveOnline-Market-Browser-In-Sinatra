def parse_boolean(value)    [true, 'true', 1, '1', 't'].include?(value.respond_to?(:downcase) ? value.downcase : value)  end

Float.class_eval do
  def comify( options = {} )
    to_s.gsub(/(\d)(?=\d{3}+(\.\d*)?$)/, '\1,')
  end
end
Integer.class_eval do
  def comify
    to_s.gsub(/(\d)(?=\d{3}+(\.\d*)?$)/, '\1,')
  end
end

class EveApi
  require 'net/http'
  require 'net/https'
  require "rexml/document"
  require 'digest/md5'
  require './eve_api/eve_data'
  require './eve_api/eve_account'

  def initialize
    eve_api = URI.parse( 'https://api.eveonline.com/' )
    @@http = Net::HTTP.new( eve_api.host, eve_api.port)
    @@http.use_ssl = true
    @@http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @@eve_accounts = Hash.new
  end

  def new_account( id, vCode )
    @@eve_accounts[id] ||= EveAccount.new(id, vCode, self)
    return @@eve_accounts[id]
  end

  def accounts
    return @@eve_accounts
  end

  def account( id )
    return @@eve_accounts[ id ]
  end

  # keyID and vCode.
  def cache_key_for( location, account, options = {} )
    return Digest::MD5.hexdigest( "#{location}-#{account.id}-#{account.vCode}-#{options.map{|k,v| "#{k}=#{v}"}.join('-')}" )
  end

  def api_req_url( url, account, options = {} )
    if options.length > 0
      option_params = '&' + options.map{|k,v| "#{k}=#{v}"}.join('&')
    else
      option_params = ""
    end
    uri = "https://api.eveonline.com#{url}?keyID=#{account.id}&vCode=#{account.vCode}#{option_params}"
    puts uri
    return uri
  end
  def http_request( url )
    uri = URI( url )
    request = Net::HTTP::Get.new(uri.request_uri)
    response = @@http.request( request )
    return response.body
  end

  # def get_cached_http_request( url, duration )
  #   if duration == "short"
  #     exp = 900
  #   elsif duration == "mshort"
  #     exp = 3600
  #   elsif duration == "long"
  #     exp = 1440
  #   else
  #     exp = 3600 * 24
  #   end
  #   key = Digest::MD5.hexdigest(url)
  #   unless output = @@cache.get( key )
  #     output = http_request( url )
  #     @@cache.set( key, output, exp )
  #   end
  #   return output
  # end
end
$eve_api_cache =  Dalli::Client.new('localhost:11211', :namespace => 'sinatra-eve/')
$eve_api = EveApi.new