require 'akamai/edgegrid'
require 'net/http'
require 'uri'
require 'json'

module AkamaiOpenApi
  class BillingCenter

    def initialize(baseuri, client_token, client_secret, access_token)
      @baseuri = URI(baseuri)
      @http = Akamai::Edgegrid::HTTP.new(@baseuri.host, @baseuri.port)
      @http.setup_edgegrid(
        client_token: client_token,
        client_secret: client_secret,
        access_token: access_token,
        max_body: 128 * 1024
      )
    end
  
    def report_sources
      get_result('/billing-usage/v1/reseller/reportSources')
    end
  
    def measures(product, startdate, enddate, source_obj)
      get_result(
        [
          '/billing-usage/v1/measures',
          product,
          source_obj['type'],
          source_obj['id'],
          startdate['month'],
          startdate['year'],
          enddate['month'],
          enddate['year']
        ].join('/')
      )
    end
  
    def statistic_types(product, startdate, enddate, source_obj)
      get_result(
        [
          '/billing-usage/v1/statisticTypes',
          product,
          source_obj['type'],
          source_obj['id'],
          startdate['month'],
          startdate['year'],
          enddate['month'],
          enddate['year']
        ].join('/')
      )
    end
  
    def monthly_report(product, startdate, statistictype, source_obj)
      get_result(
        [
          '/billing-usage/v1/contractUsageData/monthly',
          product,
          source_obj['type'],
          source_obj['id'],
          statistictype,
          startdate['month'],
          startdate['year'],
          startdate['month'],
          startdate['year']
        ].join('/')
      )
    end
  
    def products(parameter_obj, startdate, enddate)
      request = Net::HTTP::Post.new(
        URI.join(@baseuri.to_s, "/billing-usage/v1/products").to_s,
        {'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8','Accept' => 'application/json'}
      )
      request.body = "reportSources=#{[parameter_obj].to_json}&startDate=#{startdate.to_json}&endDate=#{enddate.to_json}"
      response = @http.request(request)
      JSON.parse(response.body)['contents']
    end
  
  
    private
  
    def get_result(endpoint)
      request = Net::HTTP::Get.new(URI.encode URI.join(@baseuri.to_s, endpoint).to_s)
      response = @http.request(request)
      JSON.parse(response.body)['contents']
    end
  end
end
