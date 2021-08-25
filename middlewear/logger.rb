require 'logger'

class AppLogger
  def initialize(app, **options)
    @logger = Logger.new(options[:logdev] || STDOUT)
    @app = app
  end

  def call(env)
    response = @app.call(env)

    log_request(env)
    log_response(env)
    response
  end

  def log_request(env)
    log = { request: {} }
    log[:request][:method] = env.fetch('REQUEST_METHOD',"")
    log[:request][:path] = env.fetch('REQUEST_PATH',"")
    log[:request][:handler] = valid_route(env) ? "" : env['simpler.controller'].class.name + '#' + env['simpler.action']
    log[:request][:params] =  valid_route(env) ? "" : env['simpler.controller'].params

    @logger.info(log)
  end

  def log_response(env)
    log = { response: {} }
    log[:response][:status] = valid_route(env) ? 404 : env['simpler.controller'].response.status
    log[:response][:content_type] = valid_route(env) ? "" : env['simpler.controller'].response.headers['Content-Type']
    log[:response][:view] = valid_route(env) ? "" : (env['simpler.controller'].class.name.match('(?<name>.+)Controller')[:name].downcase + '/' + env['simpler.action'] + '.html.erb')

    @logger.info(log)
  end
  
  def valid_route(env)
    env['simpler.controller'].nil?
  end
end
