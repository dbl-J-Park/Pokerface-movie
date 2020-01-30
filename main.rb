require 'sinatra'

if development?  # only run the code in development
  require 'sinatra/reloader'
  require 'pry'
  also_reload
end

require 'httparty'

require_relative 'models/db_model.rb'
require_relative 'main_login.rb'


enable :sessions

helpers do
  def current_user
      sql = "select * from user_db_table where id = #{session[:id]};"
      result =dbconnect(sql)[0]
  end

end

# using different layout 
# get '/' do
#   erb :index, :layout2 => :post
# end

get '/' do
  sql="select * from movie_db_table order by frequency desc fetch first 5 rows only;" 
  @results = dbconnect(sql)
  erb :index
end

get '/search' do
  url = "http://omdbapi.com/?s=#{params["movie"]}&apikey=#{ ENV['OMDB_API_KEY']}"
  @result = HTTParty.get(url)

  erb:search
end

get '/movie/:movie' do
  if login?
    sql ="select * from movie_db_table where Title = '#{params[:movie]}';"
    result = dbconnect(sql)
    
    if result.count ==1
      # retriving the data in the database
      @movie_title = result[0]["title"]
      @movie_year = result[0]["year"]
      @movie_runtime = result[0]["runtime"]
      @movie_genre = result[0]["genre"]
      @movie_actors = result[0]["actors"]
      @movie_rate = result[0]["ratings"]
      @movie_image = result[0]["poster"]
      @movie_award = result[0]["awards"]

      #updating frequecy in movie_db_table
      frequency = result[0]["frequency"].to_i + 1
       sql = "UPDATE movie_db_table SET frequency = #{frequency} where title = '#{@movie_title}';"
       dbconnect(sql)
      
      # generating a record in request_db_table
      sql = "insert into request_db_table (db_id, requester_id, origine) values(#{result[0]['id']},#{session[:id]},'DB');"
      dbconnect(sql)

     
    
    else 
      # retriving a new data
      url = "http://omdbapi.com/?t=#{params[:movie]}&apikey=#{ ENV['OMDB_API_KEY'] }"
      result = HTTParty.get(url)
      @movie_name = result["Title"]
      @movie_year = result["Year"]
      @movie_runtime = result["Runtime"]
      @movie_genre = result["Genre"]
      @movie_actors = result["Actors"]
      @movie_rate = result["Ratings"]
      @movie_image = result["Poster"]
      @movie_award = result["Awards"]

      # generating a record
      sql= "insert into movie_db_table (Title,Year,Runtime,Genre,Actors,Ratings,Poster,Awards,mega_data) values ('#{result["Title"]}','#{result["Year"]}','#{result["Runtime"]}','#{result["Genre"]}','#{result["Actors"]}','#{result["Ratings"]}','#{result["Poster"]}','#{result["Awards"]}','#{result}');"
      dbconnect(sql)

      # generating a record in request_db_table


       # generating a record in request_db_table
       sql = "select * from movie_db_table where title = '#{@movie_name}';"
       entryId =dbconnect(sql)[0]['id'].to_i
       sql = "insert into request_db_table (db_id, requester_id, origine) values(#{entryId},#{session[:id]},'API');"
       dbconnect(sql)
    end
  else
    redirect '/login'
  end  
  erb:movie
end
  




