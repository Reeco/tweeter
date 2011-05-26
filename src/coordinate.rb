require "rubygems"
require "data_mapper"
require "src/tweet"

class Coordinate
   include DataMapper::Resource
   property :type, String
   property :coordinates, String, :key => true
   has n, :tweets
end

