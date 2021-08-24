require_relative 'view'

module Simpler
  class Controller
    attr_reader :name, :request, :response

    def initialize(env, path_var)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      @path_var = path_var
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      set_default_headers
      send(action)
      write_response

      @response.finish
    end

    def params
      @request.params.merge(@path_var)
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_default_headers
      @response['Content-Type'] = 'text/html'
    end

    def status(value)
      @response.status = value
    end

    def headers
      @response
    end

    def write_response
      body = ''
      body = if !@request.env['simpler.body'].nil?
               @request.env['simpler.body']
             else
               render_body
             end
      @response.write(body)
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def render(options)
      if params.is_a?(Hash)
        if options.include?(:json)
          @response['Content-Type'] = 'application/json'
          @request.env['simpler.body'] = options[:json]
        elsif options.include?(:xml)
          @response['Content-Type'] = 'application/xml'
          @request.env['simpler.body'] = options[:xml]
        elsif options.include?(:plain)
          @response['Content-Type'] = 'text/html'
          @request.env['simpler.body'] = options[:plain]
        else options.include?(:js)
             @response['Content-Type'] = 'application/js'
             @request.env['simpler.body'] = options[:js]
        end
      else
        @request.env['simpler.template'] = options
      end
    end
  end
end
