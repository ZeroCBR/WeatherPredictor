require 'nokogiri'
require 'open-uri'
# require_relative 'weather_record'
# Open the HTML link with Nokogiri
URL = 'http://www.bom.gov.au/vic/observations/vicall.shtml'
URL_BASE='http://www.bom.gov.au'

class LocationLoader
	def go
		i=0		
		doc = Nokogiri::HTML(open(URL))
		rows = doc.xpath('//table/tbody/tr/th')
		details = rows.collect do |row|
			detail = {}
			[[:url,  'a/@href'],
			].each do |name, xpath|
				detail[name] = row.at_xpath(xpath).to_s.strip
			end
			detail
		end
		doc1= Nokogiri::HTML(open(URL))
		rows= doc1.xpath('//table/tbody/tr')
		locationNames = rows.collect do |row|
			locationName = {}
			[[:name, 'th[1]/a/text()'],
			].each do |name, xpath|
				locationName[name] = row.at_xpath(xpath).to_s.strip
			end
			locationName	
		end
		details.each do |item|
			url=item[:url]			
			location={}	
			doc = Nokogiri::HTML(open(URL_BASE + url ))			
			location=locationNames[i]
			str2=doc.xpath('//table/tr/td[4]/text()')
			str2=str2.to_s.lstrip
			location[:latitude]=str2.to_s.rstrip
			str3=doc.xpath('//table/tr/td[5]/text()')
			str3=str3.to_s.lstrip		
			location[:longitude]=str3.to_s.rstrip
			i+=1
			l=Location.new(location)
			l.save()				
		end
	end
end