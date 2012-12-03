require 'rubygems'
require 'sinatra'
require 'sinatra/flash'
require 'net/ldap'
require 'haml'

enable :sessions
get '/' do
  username        = params[:username]
  password 	  = params[:Password]
  haml :index
end
post '/' do
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
    redirect :change

  else
  #	 "authentication failed"
     redirect '/'
  end
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
  [:add, :deliveryMode, "noforward"],
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
  [:add, :deliveryMode, "noforward"],
  [:replace, :deliveryMode, "reply"],
   [:add, :mailReplyText, "my auto reply"],
]
  puts "#{@message}"
  ldap.modify :dn => dn, :operations => ops
 "Successfully added the Mesage"
 end
end
