module Clearance
  module HttpAuth

    # A Rack middleware which intercepts requests to your application API
    # (as defined in <tt>Configuration.api_formats</tt>) and performs
    # a HTTP Basic Authentication via <tt>Rack::Auth::Basic</tt>.
    #
    class Middleware

      def initialize(app)
        @app = app
      end

      # Wrap the application with a <tt>Rack::Auth::Basic</tt> block
      # and set the <tt>env['clearance.current_user']</tt> variable
      # if the incoming request is targeting the API.
      #
      def call(env)
        start_time = Time.now
        #puts "=== clearance http auth:"
        #puts "    env['HTTP_ACCEPT'] = #{env['HTTP_ACCEPT'].inspect}"
        #puts "    env['CONTENT_TYPE'] = #{env['CONTENT_TYPE'].inspect}"
        #puts "    env['HTTP_AUTHORIZATION'] = #{env['HTTP_AUTHORIZATION']}"
        #puts "    targeting_api?(env) = #{targeting_api?(env)}"
        if targeting_api?(env) and (env['HTTP_AUTHORIZATION'] or Configuration.bypass_auth_without_credentials == false)
          if env['HTTP_ACCEPT'].nil?
            env['HTTP_ACCEPT'] = '*/*'
            #puts "    env['HTTP_ACCEPT'] = #{env['HTTP_ACCEPT'].inspect} (after targeted api nil fix)"
          end
          @app = Rack::Auth::Basic.new(@app) do |username, password|
            result = env[:clearance].sign_in ::User.authenticate(username, password)
            #puts "    sign_in = #{result}"
            #puts "    elapsed = #{"%0.5f" % (Time.now - start_time)} sec"
            result
          end
        end
        @app.call(env)
      end

      private

      def targeting_api?(env)
        if env['action_dispatch.request.path_parameters']
          format = env['action_dispatch.request.path_parameters'][:format]
          return true if format && Configuration.api_formats.include?(format)
        end
        if Configuration.http_accept_matching
          #puts "=== env['HTTP_ACCEPT'] = #{env['HTTP_ACCEPT'].inspect}"
          return true if Configuration.api_formats.any?{|format| env['HTTP_ACCEPT'] =~ /application\/#{format}/i}
        end
        if Configuration.content_type_matching
          #puts "=== env['CONTENT_TYPE'] = #{env['CONTENT_TYPE'].inspect}"
          return true if Configuration.api_formats.any?{|format| env['CONTENT_TYPE'] =~ /application\/#{format}/i}
        end
        return false
      end

    end

  end

end
