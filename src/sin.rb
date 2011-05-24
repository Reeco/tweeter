require "rubygems"
require "bundler/setup"
require "src/timeline_sq"

get '/' do   
   haml :tweeter
end

get '/fetching_tweets' do
   screen = params[:screen_name]
   if screen.empty?
      haml :err
   else
      DataMapper.auto_migrate!
      timeline = Timeline.new(screen)
      timeline.fetch_tweets
      redirect '/search'
   end
end

get '/search' do
   @tweets_all = Tweet.all(:order => [:created_at.desc])
   haml :tweeter_search
end

@search = nil
   
get '/search/searching' do
   typ = params[:typ]
   key = params[:key]
   if typ.eql?("text")
      if key.empty?
         @err = "ERROR! Please enter the keyword."
      else
         @tweets = Tweet.all(:text.like => "%#{key}%")
      end
   elsif typ.eql?("created_at")
      if key.empty?
         @err = "ERROR! Date cannot be empty."
      else
         date = Date.parse(key)      
         puts date
         from_time = DateTime.new(date.year, date.month, date.day, 0, 0, 0)
         to_time   = DateTime.new(date.year, date.month, date.day, 23, 59, 59)
         @tweets = Tweet.all(:created_at.gte => from_time, :created_at.lte => to_time)
      end
   else
      @err = "ERROR! Type not selected."
   end
   haml :show_result
end

#get '/search/result' do
#   haml :show_result
#end
