require 'rubygems'
require 'sinatra'
require 'haml'

$weekdays = [:Montag, :Dienstag, :Mittwoch, :Donnerstag, :Freitag, :Samstag, :Sonntag]

require 'helpers'
require 'model'


# Helper
helpers do
    def date_to_str ( date )
        arr = date.to_a[3..5]
        "#{arr[2]}-#{arr[1]}-#{arr[0]}"
    end
end

# Create your model classes



# Set Haml output format and enable escapes
set :haml, {:format => :html5 , :escape_html => true }

# time record board
get '/' do
    # Just list all the time record items
    @tritems = get_all_items
    @sum_by_date = get_sum_by_date
    @projects = getProjectsFrom(@tritems)
    @messages = getMessagesFrom(@tritems)
    
    haml :index
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
    entities = AppEngine::Datastore::Query.new('TRItems').fetch
    @tritems = convert_entities_to_tritems(entities)
    puts @tritems
    @sum_by_date = get_sum_by_date
    @projects = getProjectsFrom(@tritems)
    @messages = getMessagesFrom(@tritems)
    
    haml :index
end

get '/projects' do
    tritems = TRItem.all
    projects = getProjectsFrom(tritems)
    
    haml :list, :layout => false, :locals => {:items => projects}
end


get '/messages' do
    tritems = TRItem.all
    messages = getMessagesFrom(tritems)
    
    haml :list, :layout => false, :locals => {:items => messages}
end

get '/sapp' do
    items = get_sap_records
    haml :sap, :locals => {:items => items, :show_projectname => true, :link_to_alternate_view => "sap"}
end

get '/sap' do
    items = get_sap_records
    haml :sap, :locals => {:items => items, :show_projectname => false, :link_to_alternate_view => "sapp"}
end

get '/sapprojects' do
    projects = Project.all
    haml :sapprojects, :locals => {:projects => projects}
end

post '/sapprojects' do
    if params[:id]
        save_project(params)
    else
        create_project(params)
    end

    redirect '/sapprojects'
end


def get_sap_records
    project_map = get_project_map
    items = get_items_for_current_week
    create_sap_records(items, project_map)
end

def get_project_map
    result = {}
    projects = Project.all
    projects.each do | project |
       result[project.name] = project 
    end
    result
end

def update_or_create_sap_record(sap_records, tritem, project_map)
    sap_record = sap_records[tritem.project]
    if  sap_record == nil
        if project_map[tritem.project]
            mainid = project_map[tritem.project].mainid
            subid = project_map[tritem.project].subid
        else 
            mainid = ""
            subid = ""
        end
        sap_record = SAPRecord.new($weekdays)
        sap_record.project = tritem.project
        sap_record.mainid = mainid
        sap_record.subid = subid
        sap_records[tritem.project] = sap_record
    end
    weekday = get_weekday(tritem.date)
    old_value = sap_record.instance_variable_get("@#{weekday}")
    sap_record.instance_variable_set("@#{weekday}", old_value + tritem.duration)
    p sap_record
end


def get_weekday(date)
    monday_based_weekday = (date.wday - 1) % 7
    $weekdays[monday_based_weekday]
end

def get_items_for_current_week
    monday = get_first_day_of_week(Time.now) 
    find_items_after monday
end

def get_first_day_of_week(date)
    result = Date.new(2009, 11, 30)
    return result
end

def get_all_items
    TRItem.all(:order => [:date])
    # TRItem.all(:limit => 2, :iorder => :date)
end

def get_sum_by_date
    result = {}
    TRItem.all.each do | tritem |
        value = result[tritem.date]
        if ! value
             value = 0
        end
        result[tritem.date] = value + tritem.duration
    end
    result
end


def find_items_after(date)
    result = []
    TRItem.all.each do | tritem |
        if tritem.date >= date
            result << tritem
        end
    end
    result
end

def find_items_by_id(id)
    result = []
    # list = AppEngine::Datastore::Query.new('TRItem').filter(:id, AppEngine::Datastore::Query::EQUAL, id)
    # list = DataMapper::Query.new('TRItem')
    TRItem.all.each do | tritem |
        if tritem.id == id
            result << tritem
        end
    end
    result
end

def find_project_by_id(id)
    result = nil
    Project.all.each do | project |
        if project.id == id
            result = project
        end
    end
    result
end


def save_project(params)
    id = params[:id].to_i
    project = find_project_by_id id
    if project
        project.name = params[:projectname]
        project.mainid = params[:mainid]
        project.subid = params[:subid]
        project.save
    end

end

def create_project(params)
    Project.create(:name => params[:projectname],
                   :mainid => params[:mainid],
                   :subid => params[:subid])
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
    tritem = TRItem.create(:message => params[:message],
                           :date => params[:date],
                           :project => params[:project],
                           :duration => params[:duration])
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


