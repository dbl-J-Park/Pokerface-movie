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
      sql = "select * from user_db_table where id = $1;"
      result =dbconnect(sql,[session[:id]])[0]
  end

end

def escape_naming(movie)
  moviearr = []
  movie = movie.chars
  movie.each do |item|
    if item == "/"|| item == "'"||item == "!"||item == ","
      moviearr << "/"
      moviearr << item
    else
      moviearr << item
    end 
  end
  movie = moviearr.join("")
  return movie
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
    sql ="select * from movie_db_table where Title = $1;"
    
    result = dbconnect(sql,[params[:movie]])
    
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
       sql = "UPDATE movie_db_table SET frequency = $1 where title = $2;"
       dbconnect(sql,[frequency,@movie_title])
      
      # generating a record in request_db_table
      sql = "insert into request_db_table (db_id, requester_id, origine) values($1,$2,'DB');"
      dbconnect(sql,[result[0]['id'],session[:id]])

     
    
    else 
      # retriving a new data
      url = "http://omdbapi.com/?t=#{params[:movie]}&apikey=#{ ENV['OMDB_API_KEY'] }"
      result = HTTParty.get(url)
      # megadb = result.to_json

      @movie_name = result["Title"]
      @movie_year = result["Year"]
      @movie_runtime = result["Runtime"]
      @movie_genre = result["Genre"]
      @movie_actors = result["Actors"]
      @movie_rate = result["Ratings"]
      @movie_image = result["Poster"]
      @movie_award = result["Awards"]

      # generating a record
      sql= "insert into movie_db_table (Title,Year,Runtime,Genre,Actors,Ratings,Poster,Awards) values ($1,$2,$3,$4,$5,$6,$7,$8);"
      dbconnect(sql,[result["Title"],result["Year"],result["Runtime"],result["Genre"],result["Actors"],result["Ratings"],result["Poster"],result["Awards"]])

      # generating a record in request_db_table


       # generating a record in request_db_table
       sql = "select * from movie_db_table where title = $1;"
       entryId =dbconnect(sql,[@movie_name])[0]['id'].to_i
       sql = "insert into request_db_table (db_id, requester_id, origine) values($1,$2,'API');"
       dbconnect(sql,[entryId,session[:id]])
    end
  else
    redirect '/login'
  end  
  erb:movie
end

  
get '/about' do
 erb:about
end




