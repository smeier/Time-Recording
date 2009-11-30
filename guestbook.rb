require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'haml'
require 'appengine-apis/datastore'

# Configure DataMapper to use the App Engine datastore 
DataMapper.setup(:default, "appengine://auto")

# Helper
helpers do
    def date_to_str ( date )
        arr = date.to_a[3..5]
        "#{arr[2]}-#{arr[1]}-#{arr[0]}"
    end
end

# Create your model classes

class TRItem
    include DataMapper::Resource

    property :id, Serial
    property :date, Date
    property :duration, Integer
    property :project, Text
    property :message, Text
end

# Set Haml output format and enable escapes
set :haml, {:format => :html5 , :escape_html => true }

# time record board
get '/' do
    # Just list all the time record items
    @tritems = TRItem.all
    @projects = getProjectsFrom(@tritems)
    @messages = getMessagesFrom(@tritems)
    
    haml :index
end

def find_items_by_id(id)
    result = []
    # list = AppEngine::Datastore::Query.new('TRItem').filter(:id, AppEngine::Datastore::Query::EQUAL, id)
    # list = DataMapper::Query.new('TRItem')
    TRItem.all.each do | tritem |
        puts "item.id = #{tritem.id}"
        if tritem.id == id
            puts "yay, found item.id = #{tritem.id}"
            result << tritem
        end
    end
    result
end

def save_item(params)
    id = params[:id].to_i
    list = find_items_by_id id
    list.each do | tritem |
        tritem.message = params[:message]
        tritem.date = params[:date]
        tritem.project = params[:project]
        tritem.duration = params[:duration]
        tritem.save
    end

end

def create_item(params)
    # Create a new shout and redirect back to the list
    tritem = TRItem.create(:message => params[:message],
                                                 :date => params[:date],
                                                 :project => params[:project],
                                                 :duration => params[:duration])
end

post '/' do
    if params[:id]
        save_item(params)
    else
        create_item(params)
    end

    redirect '/'
end

get '/list' do
    # @tritems = AppEngine::Datastore::Query.new('TRItem').filter('project',  AppEngine::Datastore::Query::EQUAL, '123').fetch
    @tritems = AppEngine::Datastore::Query.new('TRItemXX')
    puts @tritems
    @tritems = AppEngine::Datastore::Query.new('TRItem').fetch
    # @tritems = DataMapper::Query.new('TRItem')
    puts @tritems
    @projects = getProjectsFrom(@tritems)
    @messages = getMessagesFrom(@tritems)
    
    haml :index
end

get '/projects' do
    # Just list all the time record items
    @tritems = TRItem.all
    projects = getProjectsFrom(@tritems)
    
    haml :list, :layout => false, :locals => {:items => projects}
end


get '/messages' do
    # Just list all the time record items
    @tritems = TRItem.all
    messages = getMessagesFrom(@tritems)
    
    haml :list, :layout => false, :locals => {:items => messages}
end


def getProjectsFrom(items) 
    projects = {}
    for item in items do
        # puts item.project
        projects[item.project] = item.project
    end
    projects
end

def getMessagesFrom(items)
    messages = {}
    for item in items do
        messages[item.message] = item.message
    end
    # TODO:
    # getSetOfFieldsFromList(items, "message")
    messages
end

def getSetOfFieldsFromList(items, fieldname)
    result = {}
    for item in items do
        result[item.attr("message")] = 1
    end
    result
end 

