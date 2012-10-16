#require 'sinatra'
require 'sinatra/base'
require 'logger'
require './database'
require 'date'

class TimeSpan
  attr_accessor :span
  attr_accessor :total_seconds
  def initialize( seconds )
    @total_seconds = seconds
    span = Hash.new
    span['s'] = (seconds%60).to_i
    span['m'] = ((seconds/60)%60).to_i
    span['h'] = ((seconds/3600)%24).to_i
    span['d'] = ((seconds/86400)%365).to_i
    span['y'] = (seconds/31536000).to_i

    @span = OpenStruct.new span
  end

  def strfts( format = "%d:%h:%m:%s" )
    return format.gsub("%s", "%02d" % span.s).gsub("%m", "%02d" % span.m).gsub("%h", "%02d" % span.h).gsub("%d", "%03d" % span.d).gsub("%y", span.y.to_s)
  end

  def from_now
    @total_seconds.seconds.from_now( Time.now )
  end
end

class Date
  def dayname
     DAYNAMES[self.wday]
  end

  def abbr_dayname
    ABBR_DAYNAMES[self.wday]
  end
end

class Time
  def dayname
     Date::DAYNAMES[self.wday]
  end

  def abbr_dayname
    Date::ABBR_DAYNAMES[self.wday]
  end
end

class App < Sinatra::Base
  require 'rubygems'
  require 'date'
  require 'dalli'
  require 'haml'
  require './eve_api/eve_api'
  # configure do
  #   DataMapper.setup(:default, {
  #     :adapter  => 'mysql',
  #     :host     => 'localhost',
  #     :username => 'root' ,
  #     :password => '',
  #     :database => 'sinatra_development'})  

  #   DataMapper::Logger.new(STDOUT, :debug)
  # end

  $kazal_than = $eve_api.new_account( '', '' ) # Account ID and Key removed for GitHub.
  $sil = $eve_api.new_account( '', '' ) # Account ID and Key removed for GitHub.

  get '/' do
    $kazal_than.account_status.to_s
  end

  require './account.rb'
  require './character.rb'
  use Account
  use Character
  run! if app_file == $0
end