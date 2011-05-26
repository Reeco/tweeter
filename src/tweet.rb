require "rubygems"
require "data_mapper"

class Tweet
   include DataMapper::Resource
   property :created_at, DateTime
   property :text, String, :length => 200
   property :contributors, String, :required => false
   property :retweeted, Boolean, :required => false
   property :in_reply_to_user_id_str, String, :required => false
   property :in_reply_to_status_id_str, String, :required => false
   property :source, String, :required => false, :length => 200
   property :favorited, Boolean, :required => false
   property :retweet_count, Integer
   property :id_str, String, :key => true
   property :in_reply_to_screen_name, String, :required => false
   belongs_to :coordinate, :required => false
   belongs_to :place, :required => false
   belongs_to :user
end

