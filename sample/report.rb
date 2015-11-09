$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'akamai_open_api'

billing = AkamaiOpenApi::BillingCenter.new(
  ENV['AKAMAI_API_BASEURI'],
  ENV['AKAMAI_API_CLIENT_TOKEN'],
  ENV['AKAMAI_API_CLIENT_SECRET'],
  ENV['AKAMAI_API_ACCESS_TOKEN']
)

year, month = ARGV

report_sources = billing.report_sources
                 .select{|c| c['type'] == 'reportGroup'}
                 .sort_by{|c| c['name']}

start_date = { 'year' => year, 'month' => month }
end_date = start_date

results = {
  'HTTP Downloads' => {},
  'Object Caching' => {},
}

report_sources.each do |report_source|
  products = billing.products(report_source, start_date, end_date)
  product = products.find{|p| p['name'] == 'HTTP Downloads' || p['name'] == 'Object Caching'}
  next unless product

  measures = billing.measures(product['id'], start_date, end_date, report_source)[0]['measures']
  measure = measures.find{|m| m['name'] == "Total MB" }
  results[product['name']][report_source['name']] = measure['value'].to_f / 1000
end

require 'pp'
pp results
