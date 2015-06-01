require 'rufus-scheduler'
require_relative '../../lib/spider'

scheduler = Rufus::Scheduler.new

scheduler.in '10s' do
	Spider.extract
end

scheduler.every '600s' do
	Spider.extract
end