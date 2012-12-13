require 'rubygems'
require 'sinatra'
require 'sinatra/flash'
require 'net/ldap'
require 'sha1'
require 'base64'
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
if session[:username]
	redirect '/options'
else
   erb "Please Login to Continue"
end
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
get '/passwd' do
	
	newpassword	= params[:newpassword]
	cnewpassword	= params[:cnewpassword]
	erb :passwd
end
post '/passwd' do
	session[:newpassword] = @newpassword = params[:newpassword]
	session[:cnewpassword] = @cnewpassword = params[:cnewpassword]
	if session[:newpassword] == session[:cnewpassword]
		secret = session[:newpassword]
		salt = [Array.new(6){rand(256).chr}.join].pack("m")[0..7];
		hash = "{SSHA}"+Base64.encode64(Digest::SHA1.digest(secret+salt)+salt ).chomp!
		@hash_pass = hash
		treebase = "dc=hsit, dc=ac, dc=in"
      		ldap = Net::LDAP.new
  		ldap.host = "127.0.0.1"
  		ldap.port = 389
  		ldap.auth "uid=#{session[:username]},ou=people,#{treebase}", "#{session[:password]}"
  		dn = "uid=#{session[:username]},ou=people,#{treebase}"
  		ops = [
  		[:replace, :userPassword, "#{@hash_pass}"],
		]
  		ldap.modify :dn => dn, :operations => ops
  		erb "<div class='alert alert-message'>Password Changed Successfully</div>"
	else
		erb "<div class='alert alert-message'>Password didn't match</div>"
   end
end
get '/reply' do
message        = params[:message]
	erb :reply
end
get '/options' do
  if session[:username]
	erb :options
  else
	  redirect '/'
end
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
post '/reply' do
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
   [:add, :mailReplyText, "#{@message}"],
]
  puts " from post -- #{session[:message]}"
  ldap.modify :dn => dn, :operations => ops
  erb "<div class='alert alert-message'>Auto Reply Added Successfully</div>"
else
   redirect '/'
 end
end
get '/disable' do
	treebase = "dc=hsit, dc=ac, dc=in"
  	ldap = Net::LDAP.new
  	ldap.host = "127.0.0.1"
  	ldap.port = 389
  	ldap.auth "uid=#{session[:username]},ou=people,#{treebase}", "#{session[:password]}"
  	dn = "uid=#{session[:username]},ou=people,#{treebase}"
  	ops = [
  	[:replace, :deliveryMode, "noforward"],
   	[:delete, :mailReplyText],
	]
	ldap.modify :dn => dn, :operations => ops
	erb "<div class='alert alert-message'>Auto Reply Removed Succesfully</div>"
end
