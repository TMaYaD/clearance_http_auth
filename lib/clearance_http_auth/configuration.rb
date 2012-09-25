module Clearance
  module HttpAuth

    # Configuration is available in your Rails' <tt>application.rb</tt> as
    # <tt>config.clearance_http_auth</tt>. See README for example.
    #
    class Configuration

      # Returns formats for which the Middleware is enabled
      #
      def self.api_formats
        @api_formats ||= %w[  json xml  ]
      end

      # Some API clients will only set an Accept: header, so we can try to match
      # defined formats within this header.
      def self.http_accept_matching
        @http_accept_matching = true unless defined? @http_accept_matching
        return @http_accept_matching
      end
      def self.http_accept_matching=(value)
        @http_accept_matching = value
      end

      # enable or disable http-auth bypassing without given credentials
      # disable for User & Password input window
      def self.bypass_auth_without_credentials
        @bypass_auth_without_credentials = true unless defined? @bypass_auth_without_credentials
        return @bypass_auth_without_credentials
      end
      def self.bypass_auth_without_credentials=(value)
        @bypass_auth_without_credentials = value
      end

    end

  end

end
