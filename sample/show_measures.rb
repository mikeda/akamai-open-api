#!/usr/bin/env ruby

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'akamai_open_api'

billing = AkamaiOpenApi::BillingCenter.new(
  ENV['AKAMAI_API_BASEURI'],
  ENV['AKAMAI_API_CLIENT_TOKEN'],
  ENV['AKAMAI_API_CLIENT_SECRET'],
  ENV['AKAMAI_API_ACCESS_TOKEN']
)

year, month = ARGV
start_date = { 'year' => year, 'month' => month }
end_date = start_date

report_sources = billing.report_sources.sort_by{|c| c['name']}
report_sources.each do |report_source|
  puts report_source['name']
  products = billing.products(report_source, start_date, end_date)
  next unless products
  products.each do |product|
    puts '  ' + product['name']
    measures = billing.measures(product['id'], start_date, end_date, report_source)[0]['measures']
    measures.each do |measure|
      puts '    ' + measure.to_s
    end
  end
end
