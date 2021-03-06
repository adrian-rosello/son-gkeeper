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
require './models/manager_service.rb'

class RecordManagerService < ManagerService
  
  JSON_HEADERS = { 'Accept'=> 'application/json', 'Content-Type'=>'application/json'}
  LOG_MESSAGE = 'GtkApi::' + self.name
  
  def self.config(url:, logger:)
    method = LOG_MESSAGE + "#config(url=#{url}, logger=#{logger})"
    raise ArgumentError.new('RecordManagerService can not be configured with nil url') if url.nil?
    raise ArgumentError.new('RecordManagerService can not be configured with empty url') if url.empty?
    raise ArgumentError.new('RecordManagerService can not be configured with nil logger') if logger.nil?
    @@url = url
    @@logger = logger
    @@logger.debug(method) {'entered'}
  end
    
  def self.find_records(params)
    method = LOG_MESSAGE + ".find_records(#{params})"
    @@logger.debug(method) {'entered'}
    kind = params['kind']
    params.delete('kind')

    begin
      @@logger.debug(method) {'getting '+kind+' from '+@@url}
      response = getCurb(url: @@url + '/' + kind, params: params, headers: JSON_HEADERS, logger: @@logger) 
      @@logger.debug(method) {'response=' + response.body}
      JSON.parse response.body
    rescue => e
      @@logger.error(method) {"Error during processing: #{$!}"}
      @@logger.error(method) {"Backtrace:\n\t#{e.backtrace.join("\n\t")}"}
      nil 
    end
  end
  
  def self.find_service_by_uuid(uuid)
    method = LOG_MESSAGE + ".find_service_by_uuid(#{uuid})"
    @@logger.debug(method) {'entered'}
    begin
      response = getCurb(url: @url+'/services/'+uuid, headers: JSON_HEADERS, logger: @@logger) 
      @@logger.debug(method) {'response='+response.body}
      JSON.parse response.body
    rescue => e
      @@logger.error(method) {"Error during processing: #{$!}"}
      @@logger.error(method) {"Backtrace:\n\t#{e.backtrace.join("\n\t")}"}
      nil 
    end
  end
  
  def self.get_log
    method = 'GtkApi::' + CLASS_NAME + ".get_log()"
    @@logger.debug(method) {'entered'}

    response=getCurb(url: @@url+'/admin/logs', headers: {'Content-Type' => 'text/plain; charset=utf8', 'Location' => '/'}, logger: @@logger)
    @@logger.debug(method) {'status=' + response.response_code.to_s}
    case response.response_code
      when 200
        response.body
      else
        @@logger.error(method) {"Error during processing: #{$!}"}
        @@logger.error(method) {"Backtrace:\n\t#{e.backtrace.join("\n\t")}"}
        nil
      end
  end
end
