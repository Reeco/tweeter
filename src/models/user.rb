require "rubygems"
require "data_mapper"
require "src/models/tweet"

class User
   include DataMapper::Resource
   property :lang, String
   property :statuses_count, Integer
   property :description, String, :required => false, :length => 200
   property :followers_count, Integer
   property :time_zone, String, :required => false
   property :created_at, Time
   property :name, String
   property :screen_name, String
   property :id_str, String, :key => true
   has n, :tweets
end

