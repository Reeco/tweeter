require "rubygems"
require "sinatra"
require "bundler/setup"
require "src/timeline_sq"
require "src/tweet"

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, ENV["DATABASE_URL"]||"sqlite3://#{(Dir.pwd).chomp("src")}db/tweets.db")

get '/' do   
   haml :tweeter
end

get '/fetching_tweets' do
   screen = params[:screen_name]
   if screen.empty?
      @err = "ERROR! Screen name cannot be blank"
      haml :err
   else
      DataMapper.finalize
      DataMapper.auto_migrate!
      timeline = Timeline.new(screen)
      @err = timeline.fetch_tweets
      if @err.nil?
         redirect '/search'
      else
         haml :err
      end
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
         @err = "No match found." if @tweets.empty?
      end
   elsif typ.eql?("created_at")
      if key.empty?
         @err = "ERROR! Date cannot be empty."
      elsif key =~ /\d\d\d\d-\d\d-\d\d/
         date = Date.parse(key)
         tod = Date.today
         if date.year>tod.year || date.year <1 || date.month <1 || date.month >tod.month || date.day <1 || date.day >tod.day 
            @err = "ERROR! Invalid Date."     
         else
            from_time = DateTime.new(date.year, date.month, date.day, 0, 0, 0)
            to_time   = DateTime.new(date.year, date.month, date.day, 23, 59, 59)
            @tweets = Tweet.all(:created_at.gte => from_time, :created_at.lte => to_time)          
            @err = "No match found." if @tweets.empty?
         end
      else
         @err = "ERROR! Please enter the date in correct format."
      end
   else
      @err = "ERROR! Type not selected."
   end
   haml :show_result
end
