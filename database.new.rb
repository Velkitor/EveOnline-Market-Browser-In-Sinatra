require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/evedump.sqlite3")

class InvTypes 
  include DataMapper::Resource

  property :typeId, Integer
  property :groupID, Integer
  property :typeName, String
  property :description, String
  property :graphicID, Integer
  property :radius, Float
  property :mass, Float
  property :volume, Float
  property :capacity, Float
  property :portionSize, Integer
  property :raceID, Integer
  property :basePrice, Float
  property :published, Boolean
  property :marketGroupID, Integer
  property :chanceOfDuplicating, Float
  property :iconID, Integer


end

DataMapper.auto_migrate!

