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

