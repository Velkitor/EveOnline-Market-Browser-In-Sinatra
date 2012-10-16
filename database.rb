require 'sinatra'
require 'sinatra/activerecord'
require 'mysql2'

#Data source
#set :database, "mysql2://evedump:evedump1234@db.descention.net/evedump"
#con = Mysql2::Client.new(:host => "db.descention.net", :username => "evedump", :password => "evedump1234", :database => "evedump")
# Handy export of a model to CSV
# require 'csv'
# cNames = Model.column_names
# CSV.open( "./filename", "wb") do |csv|
#   csv << cNames
#   Model.all.each do |item|
#     row = Array.new
#     attr = item.attributes
#     cNames.each do |column|
#       row << attar[column]
#     end
#   end
# end
set :database, "mysql2://root:@localhost/eve_static"

class InvTypes < ActiveRecord::Base
  set_table_name "invTypes"

end