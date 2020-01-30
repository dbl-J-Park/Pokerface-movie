require 'sinatra'
require 'pry'

require_relative 'models/db_model.rb'
require_relative 'models/pw_crypt.rb'

def login?
  if session[:id] != nil
    return true
  else 
    return false
  end
end


get '/login' do
  erb:login
end

get '/logout' do
  session[:id]= nil
  session[:name] = nil
 erb:login
end


get '/signin' do
  erb:signin
end


post '/login' do
  sql="select * from user_db_table where email = '#{params[:user_email]}';"
  results = dbconnect(sql)
  if results.count ==1
    if varify_password?(results[0]['processed_password'],params[:user_passward])
      session[:id] = results[0]['id']
      redirect '/'
    else 
      "your password is wrong"
    end
  else 
      @login_status = "Your email is not enrolled, please enroll your account. "
      redirect '/signin'
  end

end



post '/signin' do
  sql ="select * from user_db_table where email = '#{params[:user_email]}';"
  result = dbconnect(sql)
  if result.count == 1
    redirect'/login'
  else
    secure_password = password_hiding(params[:user_passward])
    sql= "insert into user_db_table (name, email, processed_password) values ('#{params[:user_name]}','#{params[:user_email]}','#{secure_password}');"
    dbconnect(sql)

    sql="select * from user_db_table where email = '#{params[:user_email]}';"
    results = dbconnect(sql)
    if results.count ==1
      if varify_password?(results[0]['processed_password'],params[:user_passward])
        session[:id] = results[0]['id']
        session[:user_name] = results[0]['name']
        redirect '/'
      end
    end
  end
end


