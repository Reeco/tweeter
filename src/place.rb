require "rubygems"
require "data_mapper"
require "src/tweet"

class Place
   include DataMapper::Resource
   property :url, String, :length => 200
   property :street_address, String, :length => 200
   property :full_name, String, :length => 200
   property :name, String
   property :country_code, String
   property :id, String, :key => true
   property :country, String
   has n, :tweets 
end

