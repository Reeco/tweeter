require "rubygems"
require "data_mapper"
require "net/http"
require "json"
require "models/tweet"

class Timeline
   attr_accessor :user_id
   
   def initialize(screenname)
      @screen_name = screenname
   end
   
   def fetch_tweets
      user = nil
      err = nil
      (1...10).each do |i|
         begin
            resp = Net::HTTP.get_response(URI.parse("http://api.twitter.com/1/statuses/user_timeline.json?page=#{i}&screen_name="+@screen_name))
         rescue Exception
            puts "Twitter API not responding. Program will exit now."
            Process.exit
         else
            tweets = JSON.parse(resp.body)
         end
         if tweets.include?("error")
            err = "No user with this screen_name" 
            break
         end
         coordinate = nil
         place = nil
         tweet = nil
         source = nil
         tweets.each {|status|
            if(user.nil?) 
               user = User.new 
               a = status["user"]
               user.lang = a["lang"]
               user.statuses_count = a["statuses_count"]
               user.description = a["description"]
               user.followers_count = a["followers_count"]
               user.time_zone = a["time_zone"]
               user.created_at = a["created_at"]
               user.name = a["name"]
               user.screen_name = a["screen_name"]
               user.id_str = a["id_str"]
            end
            if status["coordinates"].nil?
               coordinate = nil
            else
               coordinate = Coordinate.new
               coordinate.type = status["coordinates"]["type"]
               coordinate.coordinates = status["coordinates"]["coordinates"][0].to_s + "," + status["coordinates"]["coordinates"][1].to_s
            end
            if status["place"].nil?
               place = nil
            else
               place = Place.new
               place.url = status["place"]["url"]
               place.street_address = status["place"]["street_address"], String
               place.full_name = status["place"]["full_name"]
               place.name = status["place"]["name"]
               place.country_code = status["place"]["country_code"]
               place.id = status["place"]["id"]
               place.country = status["place"]["country"]
            end
            tweet = Tweet.create( 
               :created_at => DateTime.parse(status["created_at"]),
               :text => status["text"],
               :contributors => status["contributors"],
               :retweeted => status["retweeted"],
               :in_reply_to_user_id_str => status["in_reply_to_user_id_str"],
               :in_reply_to_status_id_str => status["in_reply_to_status_id_str"],
               :source => status["source"],
               :favorited => status["favorited"],
               :retweet_count => status["retweet_count"],
               :id_str => status["id_str"],
               :in_reply_to_screen_name => status["in_reply_to_screen_name"],
               :user => user,
               :coordinate => coordinate,
               :place => place
            )
            user.tweets << tweet 
            if coordinate and !Coordinate.get(coordinate.coordinates)
               coordinate.tweets << tweet 
               place.save
            end
            if place and !Place.get(place.id)
               place.tweets << tweet 
               coordinate.save
            end
         }
         user.save
      end
      return err
   end
end

