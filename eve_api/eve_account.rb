require './eve_api/eve_api'
require './eve_api/eve_data'
require './eve_api/eve_character'

class EveAccount
  attr_reader :id, :vCode
  def initialize( id, vCode, eve_api)
    @id = id
    @vCode = vCode
  end

  def account_status
    key = $eve_api.cache_key_for("/account/AccountStatus.xml.aspx", self)
    unless output = $eve_api_cache.get( key )
      xml = $eve_api.http_request( $eve_api.api_req_url('/account/AccountStatus.xml.aspx', self ) )

      doc = REXML::Document.new xml

      output = Hash.new
      begin
        output['paidUntil'] = doc.elements['eveapi'].elements['result'].elements['paidUntil'].text
        output['createDate'] = doc.elements['eveapi'].elements['result'].elements['createDate'].text
        output['loginCount'] = doc.elements['eveapi'].elements['result'].elements['logonCount'].text
        output['logonMinutes'] = doc.elements['eveapi'].elements['result'].elements['logonCount'].text

        output['cachedUntil'] = doc.elements['eveapi'].elements['cachedUntil'].text
        $eve_api_cache.set( key, output, (Time.parse( output['cachedUntil'] ) - Time.now.utc ) )
      rescue
        output['raw'] = xml
      end
    end
    return output
  end

  def api_key_info
    key = $eve_api.cache_key_for("/account/APIKeyInfo.xml.aspx", self)
    unless output = $eve_api_cache.get( key )
      xml = $eve_api.http_request( $eve_api.api_req_url('/account/APIKeyInfo.xml.aspx', self) )

      doc = REXML::Document.new xml
      output = Hash.new

      output['doc'] = xml
      output['cachedUntil'] = doc.elements['eveapi'].elements['cachedUntil'].text
      $eve_api_cache.set( key, output, (Time.parse( output['cachedUntil'] ) - Time.now.utc ) )
    end
    return output
  end

  def characters( options = {} )
    if ( @characters != nil && @characters.length > 0 ) && options[:fresh] != true
      return @characters
    end
    key = $eve_api.cache_key_for("/account/Characters.xml.aspx", self)
    unless @characters = $eve_api_cache.get( key )
      @characters = Hash.new
      xml = $eve_api.http_request( $eve_api.api_req_url('/account/Characters.xml.aspx', self) )
      output = EveData.new xml
      output.data.each do |k,v|
        character = EveCharacter.new( k, self )
        character.name = v.name
        character.corporation_id = v.corporationID
        character.corporation_name = v.corporationName
        @characters[k] = character
      end
      $eve_api_cache.set( key, @characters, ( output.cached_until - Time.now.utc ) )
    end
    return @characters
  end

  def character( id )
    unless @characters
      characters( :fresh => true )
    end
    return @characters[ id ]
  end
end