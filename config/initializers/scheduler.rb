# require 'rufus-scheduler'
# require_relative '../../lib/locationLoader'
#
# scheduler = Rufus::Scheduler.new
# l=LocationLoader.new
# l.go()
#
# scheduler.every '1800s' do
# 	l=LocationLoader.new
# 	l.go()
# end

require 'rufus-scheduler'
require_relative '../../lib/spider'

scheduler = Rufus::Scheduler.new
spider = Spider.new
# spider.extract_location
# spider.extract_weather

scheduler.every '600s' do
	spider = Spider.new
	spider.extract_location
	spider.extract_weather
end