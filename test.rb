require 'helpers'
require 'test/unit'
require 'date'
# require 'rack/test'
# set :environment, :test

class GuestbookTest < Test::Unit::TestCase
    # include Rack::Test::Methods

    def app
        Sinatra::Application
    end

    def not_test_it_says_hello_world
        get '/'
        assert last_response.ok?
        assert_equal 'Hello World', last_response.body
    end

    def test_that_will_succeed
        assert_equal 'abc', 'abc'
    end

    def test_format_hh_mm
        minutes = 0
        assert_equal("0:00", format_hh_mm(minutes)) 
        minutes = 60
        assert_equal("1:00", format_hh_mm(minutes)) 
        minutes = 55
        assert_equal("0:55", format_hh_mm(minutes)) 
        minutes = 122
        assert_equal("2:02", format_hh_mm(minutes)) 
        minutes = 322
        assert_equal("5:22", format_hh_mm(minutes)) 
    end

    def test_format_hh_min_as_decimal
        minutes = 18
        assert_equal("0,3", format_hh_min_as_decimal(minutes)) 
        minutes = 80
        assert_equal("1,33", format_hh_min_as_decimal(minutes)) 
        minutes = 301
        assert_equal("5,02", format_hh_min_as_decimal(minutes)) 
    end

    def dont_test_filter_items_get_those_after
        items = TRItem.new
    end

    def test_get_first_day_of_week
        date = Date.civil(2009, 12, 9)
        monday = get_first_day_of_week(date)
        assert_equal(Date.new(2009, 12, 7), monday)

        date = Date.civil(2009, 12, 13)
        monday = get_first_day_of_week(date)
        assert_equal(Date.new(2009, 12, 7), monday)

        date = Date.civil(2009, 12, 7)
        monday = get_first_day_of_week(date)
        assert_equal(Date.new(2009, 12, 7), monday)

        date = Date.civil(2009, 12, 6)
        monday = get_first_day_of_week(date)
        assert_equal(Date.new(2009, 11, 30), monday)

        date = Date.civil(2009, 12, 4)
        monday = get_first_day_of_week(date)
        assert_equal(Date.new(2009, 11, 30), monday)

        date = Date.today
        monday = get_first_day_of_week(date)
        assert_equal(Date.new(2009, 12, 7), monday)
    end

    def test_get_sap_records
        
    end
end

