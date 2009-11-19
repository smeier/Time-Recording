require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'haml'

# Configure DataMapper to use the App Engine datastore 
DataMapper.setup(:default, "appengine://auto")

# Create your model classes
class Shout
  include DataMapper::Resource

  property :id, Serial
  property :message, Text
end

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
  
  haml :index
end

post '/' do
  # Create a now shout and redirect back to the list
  tritem = TRItem.create(:message => params[:message],
                         :date => params[:date],
                         :project => params[:project],
                         :duration => params[:duration])
  redirect '/'
end


def getProjectsFrom(items) 
  projects = {}
  for item in items do
    projects[item.project] = item.project
  end
  
end
