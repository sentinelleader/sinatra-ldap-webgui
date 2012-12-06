require 'rubygems'
require 'sinatra'
require 'sinatra/flash'
require 'net/ldap'
require 'haml'

configure do
  set :public_folder, Proc.new { File.join(root, "static") }
  enable :sessions
end

helpers do
  def identity
    session[:username] ? session[:username] : 'Hello User'
  end
end

get '/' do
  erb "Please Login to Continue"
end
get '/login' do
  username        = params[:username]
  password 	  = params[:Password]
  erb :login
end
post '/login' do
session[:username] = @username = params[:username]
session[:password] = @password = params[:password]
  ldap = Net::LDAP.new
  treebase = "dc=hsit, dc=ac, dc=in"
  ldap.host = "127.0.0.1"
  ldap.port = 389
  ldap.auth "uid=#{@username},ou=people,#{treebase}", "#{@password}"
  if ldap.bind
# 	" authentication succeeded"
   puts "#{session[:username]} --- redirecting " 
    redirect :options

  else
  #	 "authentication failed"
     redirect '/'
  end
end
get '/options' do
	erb :options
end
get '/logout' do
	  session.delete(:username)
	    erb "<div class='alert alert-message'>Logged out</div>"
end
get '/change' do
# if session[:username]    
puts "----- after redirection #{session[:username]}"
  haml :change
#else
#puts "here--------"
#redirect '/' 
# end
end
post '/change' do
  if session[:username]
treebase = "dc=hsit, dc=ac, dc=in"
  session[:message] = @message = params[:message]
  ldap = Net::LDAP.new
  ldap.host = "127.0.0.1"
  ldap.port = 389
  ldap.auth "uid=#{session[:username]},ou=people,#{treebase}", "#{session[:password]}"
dn = "uid=#{session[:username]},ou=people,#{treebase}"
  ops = [
#  [:add, :deliveryMode, "noforward"],
  [:replace, :deliveryMode, "reply"],
   [:add, :mailReplyText, "my auto reply"],
]
  puts "#{@message}"
  ldap.modify :dn => dn, :operations => ops
else
  puts "reconnecting to ldap"
  puts "user --- #{@user}"
   session[:message] = @message = params[:message]
  ldap = Net::LDAP.new
  treebase = "dc=hsit, dc=ac, dc=in"
  ldap.host = "127.0.0.1"
  ldap.port = 389
  ldap.auth "uid=#{@user},ou=people,#{treebase}", "#{@pass}"
  dn = "uid=#{@user},ou=people,#{treebase}"
  ops = [
#  [:add, :deliveryMode, "noforward"],
  [:replace, :deliveryMode, "reply"],
   [:add, :mailReplyText, "my auto reply"],
]
  puts "#{@message}"
  ldap.modify :dn => dn, :operations => ops
 "Successfully added the Mesage"
 end
end
