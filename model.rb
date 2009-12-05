class TRItem
    include DataMapper::Resource

    property :id, Serial
    property :date, Date
    property :duration, Integer
    property :project, Text
    property :message, Text
end

