require "rexml/document"

class EveData
  require 'ostruct'

  def initialize( xml )
    @doc = REXML::Document.new xml
    
    @cached_until = Time.parse( @doc.elements['eveapi'].elements['cachedUntil'].text )

    @data = Hash.new
    begin
      rowset = @doc.elements['eveapi'].elements['result'].elements['rowset']

      columns = rowset.attributes['columns'].split(',')
      key_name = rowset.attributes['key']
      eve_type = ('Eve' + rowset.attributes['name'].capitalize)

      rowset.elements.each('row') do |row|
        tmp = Hash.new
        key = row.attributes[key_name]
        tmp['eve_type'] = eve_type
        columns.each do |column|
          tmp[column] = row.attributes[column]
        end

        @data[key] = OpenStruct.new tmp
      end
    rescue
      @data['raw'] = xml
    end
  end

  def data
    return @data || Hash.new
  end

  def cached_until
    return @cached_until
  end
end