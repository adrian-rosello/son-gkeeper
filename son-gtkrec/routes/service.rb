## SONATA - Gatekeeper
##
## Copyright (c) 2015 SONATA-NFV [, ANY ADDITIONAL AFFILIATION]
## ALL RIGHTS RESERVED.
## 
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
## 
##     http://www.apache.org/licenses/LICENSE-2.0
## 
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
## 
## Neither the name of the SONATA-NFV [, ANY ADDITIONAL AFFILIATION]
## nor the names of its contributors may be used to endorse or promote 
## products derived from this software without specific prior written 
## permission.
## 
## This work has been performed in the framework of the SONATA project,
## funded by the European Commission under Grant number 671517 through 
## the Horizon 2020 and 5G-PPP programmes. The authors would like to 
## acknowledge the contributions of their colleagues of the SONATA 
## partner consortium (www.sonata-nfv.eu).
# encoding: utf-8
require 'json' 
require 'pp'
require 'addressable/uri'

class GtkRec < Sinatra::Base

  get '/services/?' do
    method = MODULE + ' GET /services'
    logger.debug(method) {"entered with params #{params}"}

    uri = Addressable::URI.new

    # Remove list of wanted fields from the query parameter list
    field_list = params.delete('fields')
    uri.query_values = params
    logger.debug(method) {'uri.query='+uri.query}
    
    services = NService.new(settings.services_repository, logger).find(params)
    if services
      logger.debug(method) { "services=#{services}"}

      if field_list
        fields = field_list.split(',')
        logger.debug(method) {"fields=#{fields}"}
        response = services.to_json(:only => fields)
      else
        response = services.to_json
      end
      logger.debug(method) {'leaving with response='+response}
      halt 200, response
    else
      logger.debug(method) {"leaving with \"No service with params #{uri.query} was found\""}
      json_error 404, "No service with params #{uri.query} was found"
    end
  end
  
  get '/services/:uuid' do
    method = MODULE + ' GET /services/:uuid'
    logger.debug(method) {"entered with :uuid=#{params[:uuid]}"}
    
    service = NService.new(settings.services_repository, logger).find_by_uuid(params[:uuid])
    if service
      logger.debug(method) {"service: #{service}"}
      response = service.to_json
      logger.debug(method) {"leaving with response="+response}
      halt 200, response
    else
      logger.debug(method) {"leaving with \"No service with uuid #{params[:uuid]} was found\""}
      json_error 404, "No service with uuid #{params[:uuid]} was found"
    end
  end

  get '/admin/logs' do
    method = MODULE + ' GET /admin/logs'
    logger.debug(method) {'entered'}
    File.open('log/'+ENV['RACK_ENV']+'.log', 'r').read
  end  
end
