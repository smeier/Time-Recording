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
    def initialize(weekdays)
        for day in weekdays
            attr_accessor day
        end
        project = "undefined"
        mainid = 0
        subid = 0
        for day in weekdays
            instance_variable_set("@#{day}", 0) 
        end
    end
end

