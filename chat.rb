require 'rubygems'
require 'sinatra'
require 'appengine-apis/logger'
require 'appengine-apis/datastore'
require 'json'
require 'dm-core'
 
# Configure DataMapper to use the App Engine datastore 
DataMapper.setup(:default, "appengine://auto")

class Chat
    include DataMapper::Resource

    property :id, Serial
    property :name, Text
    property :message, Text
end


get '/' do
  logger.info "Sinatra in your Google Appengine p0wning your JRuby"
  "I AM SINATRA! Doing a ditty for you on Google Appengine with JRuby!" 
  Chat.create(:id => 1, :name => "chat 1", :message => "Dies ist ein Chat")
end

get '/chats' do
  chats = AppEngine::Datastore::Query.new('Chats').fetch
  chats_array = []
  chats.each do |chat|
    #chats_array << chat.to_hash
    begin
      logger.info chat.to_hash.inspect
    rescue => err
      logger.info err
    end
  end
  chats_array.to_json
end

post '/bot' do
  logger.info "Received: " + params.inspect
  begin
    log_chat params
    #rebuilt_chat = rebuild_chat params
    "Echo: " + params["msg"]
  rescue => err
    err
  end
end

def logger
  AppEngine::Logger.new
end

def log_chat(params)
  chat = AppEngine::Datastore::Entity.new('Chats')
  params.each do |key, value|
    chat[key.to_sym] = "#{value}"
  end
  
  result = AppEngine::Datastore.put chat
  logger.info chat.inspect
end

def rebuild_chat(chat)
  rebuilt_chat = chat["msg"]
  if chat["step"]
    chat["step"].to_i.times do
      rebuilt_chat = rebuilt_chat + chat["value#{chat["step"].to_i - 1}"]
    end
  end
  rebuilt_chat
end
