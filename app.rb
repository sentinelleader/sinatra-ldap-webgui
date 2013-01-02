require 'rubygems'
require 'sinatra'
require 'sinatra/flash'
require 'net/ldap'
require 'sha1'
require 'base64'
require 'date'

configure do
  set :public_folder, Proc.new { File.join(root, "static") }
  enable :sessions
end

helpers do
  def identity
    session[:username] ? session[:username] : 'Hello User'
  end
end
t = Time.now
$epoch_sec = t.to_i
d = Date.today
epoch = Date.new(1970,1,1)
$epoch_days = d - epoch



get '/' do
#	p "user is #{session[:username]}"
	if (session[:username] == "Hello User" || session[:username] == nil) 
	#if session[:username]	
        p "#{session[:username]}"
#	redirect '/options'
#	else
   	   erb "Please Login to Continue"
	else
        redirect '/options'
	end
end

get '/login' do
	puts "#{$epoch_sec} ----> #{$epoch_days}"
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
 puts	" authentication succeeded"
   puts "im hereeeeeeee"
	  puts "#{session[:username]} --- redirecting " 
    	       redirect '/options'

  	    else
puts  	 "authentication failed"
   	       session[:username] = "Hello User"
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
		x = Net::LDAP::Filter.eq("shadowMax", "*")
		y = Net::LDAP::Filter.eq("uid", "#{session[:username]}")
		filter = x & y
	#	max = 0
	#	puts max
		ldap.search(:base => treebase, :filter => filter,
			                :return_result => true) do |entry|
			@max = entry.shadowMax
		end
			max1 = @max[0].to_i
			puts "shadow max is #{max1}"
			if max1 == '-1'
  			  ops = [
  			  [:replace, :userPassword, "#{@hash_pass}"],
			  [:replace, :shadowLastChange, "#{$epoch_days}"],
			  [:replace, :sambaPwdLastSet, "#{epoch_sec}"],
			  ]
			else
				$max_sec = $epoch_sec + (max1 * 86400) 
				$max_days = $epoch_days + max1
			  ops = [
			  [:replace, :userPassword, "#{@hash_pass}"],
                          [:replace, :shadowLastChange, "#{$epoch_days}"],
			  [:replace, :shadowExpire, "#{$max_days}"],
                          [:replace, :sambaPwdLastSet, "#{$epoch_sec}"],
			  [:replace, :sambaPwdCanChange, "#{$max_sec}"],
		          [:replace, :sambaPwdMustChange, "#{$max_sec}"],
                          ]
			 end
  		ldap.modify :dn => dn, :operations => ops
  		erb "<div class='alert alert-message'>Password Changed Successfully</div>"
	  else
		erb "<div class='alert alert-message'>Password didn't match</div>"
     end
end

get '/reply' do
	message        = params[:message]
	checkbox       = params[:checkbox].nil? ? false : true
	erb :reply
end

get '/options' do
  if session[:username] 
	 p #{session[:username]}" 
#	if session[:username] != 'Hello User'
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
	   session[:checkbox] = @checkbox = params[:checkbox]
	   puts @checkbox
	     if session[:checkbox] == "true"
 		if session[:username]
  		   treebase = "dc=hsit, dc=ac, dc=in"
  		   session[:message] = @message = params[:message]
  		   ldap = Net::LDAP.new
  		   ldap.host = "127.0.0.1"
  		   ldap.port = 389
  		   ldap.auth "uid=#{session[:username]},ou=people,#{treebase}", "#{session[:password]}"
  	   	   dn = "uid=#{session[:username]},ou=people,#{treebase}"
  		     ops = [
 		     [:replace, :deliveryMode, "reply"],
   		     [:add, :mailReplyText, "#{@message}"],
  		     ]
 		   puts " from post -- #{session[:message]}"
  		   ldap.modify :dn => dn, :operations => ops
  		   dn = "uid=#{session[:username]},ou=people,#{treebase}"
  		   ldap.delete_attribute dn, :mailForwardingAddress
  	           erb "<div class='alert alert-message'>Auto Reply Added Successfully</div>"
		else
   		   redirect '/'
 		end
	      else
	   	erb "<div class='alert alert-message'>checkbox not selected</div>"
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
