require 'rufus-scheduler'
require_relative '../../lib/spider'

scheduler = Rufus::Scheduler.new

Spider.extract

scheduler.every '600s' do
	Spider.extract
end