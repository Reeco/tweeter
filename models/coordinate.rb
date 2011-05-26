require "rubygems"
require "data_mapper"
require "models/tweet"

class Coordinate
   include DataMapper::Resource
   property :type, String
   property :coordinates, String, :key => true
   has n, :tweets
end

