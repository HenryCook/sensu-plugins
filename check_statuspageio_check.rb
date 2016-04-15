#! /usr/bin/env ruby
#
#   check_statuspageio_status.rb
#
# DESCRIPTION:
#   Interacts with StatusPage.io page to check the system status of whatever service's api endpoint you want check.
#
# OUTPUT:
#   plain-text
#
# PLATFORMS:
#   All
#
# DEPENDENCIES:
#   gem: net/http
#   gem: json
#   gem: sensu-plugin
#
# USAGE:
#   ./check_statuspageio_check.rb -e http://pclby00q90vc.statuspage.io/api/v2/summary.json
#
# NOTES:
#
#
# LICENSE:
#   Henry Cook
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'json'
require 'net/http'
require 'sensu-plugin/check/cli'

# Check the status of Github via their Status JSON API

class CheckSystemStatus < Sensu::Plugin::Check::CLI
  
  option :endpoint,
         description: 'StatusPage.io endpoint url',
         short: '-e ENDPOINT',
         long: '--endpoint ENDPOINT',
         required: true
    
  def run
    # This endpoint has the last message + status
    api_endpoint = config[:endpoint]

    # Get JSON from endpoint
    uri = URI.parse(api_endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    json = JSON.parse http.get(uri.request_uri).body

    status_description = json['status']['description']
    status_indicator = json['status']['indicator']
    service_name = json['page']['name']
      
    # Keys are status, body, created_on
    if status_indicator == "none"
      ok "#{service_name} is operational, message: '#{status_description}'"
    elsif status_indicator == "major"
      warning "#{service_name} is experiencing '#{status_indicator}' issues, message: '#{status_description}', reason: '#{json['incidents'][0]['name']}'"
    elsif status_indicator == "minor"
      critical "#{service_name} is experiencing '#{status_indicator}' issues, message: '#{status_description}', reason: '#{json['incidents'][0]['name']}'"
    else 
      unknown "The current operational status of #{service_name} is unknown"
    end
  end
end