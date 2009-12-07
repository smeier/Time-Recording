require 'appengine-apis/datastore'
require 'dm-core'

# Configure DataMapper to use the App Engine datastore 
DataMapper.setup(:default, "appengine://auto")

class TRItem
    include DataMapper::Resource

    property :id, Serial
    property :date, Date
    property :duration, Integer
    property :project, Text
    property :message, Text

    def self.create_from_map(props)
        tritem = TRItem.new
        tritem.initialize_from_map(props)
        tritem
    end
        
    def initialize_from_map(props)
        for prop in [:id, :date, :duration, :project, :message]
            self.send "#{prop}=", props[prop]
        end
    end

    def to_s
        return "ID: #{id}, #{message}, #{project}, #{date}, #{duration}"
    end
end

class Project
    include DataMapper::Resource

    property :id, Serial
    property :name, Text
    property :mainid, Integer
    property :subid, Integer
end

class SAPRecord
    attr_accessor :project
    attr_accessor :mainid
    attr_accessor :subid
    for day in $weekdays
        attr_accessor day
    end
    def initialize(weekdays)
        project = "undefined"
        mainid = 0
        subid = 0
        for day in weekdays
            instance_variable_set("@#{day}", 0) 
        end
    end
end

def convert_entities_to_tritems(entities)
    result = []
    for entity in entities
        result << TRItem.create_from_map(entity)
    end
    return result
end

