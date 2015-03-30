require 'evma_httpserver'
require 'logger'

class RemdWeb < EM::Connection
  include EM::HttpServer

  attr_accessor :logger, :executor

  def initialize(opts={})
    @opts = opts[:config]
    @executor = opts[:executor]
    @logger = opts[:logger] || Logger.new(STDOUT)
  end

  def post_init
     super
     no_environment_strings
   end  

   def process_http_request
    # the http request details are available via the following instance variables:
    #   @http_protocol
    #   @http_request_method
    #   @http_cookie
    #   @http_if_none_match
    #   @http_content_type
    #   @http_path_info
    #   @http_request_uri
    #   @http_query_string
    #   @http_post_content
    #   @http_headers

    logger.info "Web Request: #{@http_request_uri}"

    req_controller = /^\/(\w+)/.match(@http_request_uri)

    unless req_controller
      render404
      return
    end

    case req_controller[1]
    when 'start'
      start_exec
    when 'restart'
      restart
    when 'status'
      status
    when 'update'
      update
    when 'stop'
      stop_exec
    else
      render404
    end
  end

  def start_exec
    executor.start
    send_json(
      result: 'ok',
      status: executor.status!
    )
  end

  def stop_exec
    executor.stop
    send_json(
      result: 'ok',
      status: executor.status!
    )
  end

  def restart(respond = false)
    executor.stop
    executor.start
    send_json(
      result: 'ok',
      status: executor.status!
    )
  end

  def update
    executor.stop
    # update
    executor.start
    send_json(
      result: 'ok',
      status: executor.status!
    )
  end

  def status
    send_json(
      result: 'ok',
      status: executor.status!
    )
  end

  def render404
    response = EM::DelegatedHttpResponse.new(self)
    response.status = 404
    response.content_type 'text/html'
    response.content = 'Not found'
    response.send_response
  end

  def send_json(data = {})
    response = EM::DelegatedHttpResponse.new(self)
    response.status = 200
    response.content_type 'application/json'
    response.content = data.to_json
    response.send_response
  end


end