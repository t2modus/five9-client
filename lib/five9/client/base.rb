# frozen_string_literal: true

module Five9
  module Client
    # This class is the base class containing all logic common to all
    # Five9 API classes
    class Base
      ARRAY_TAG_REGEXP = /^\s*<[a-zA-Z]+ type="array">/
      NOT_CONFIGURED_ERROR = 'Five9 Client is not configured! Please configure it before attempting to make a request'

      def method_missing(name, *args)
        if self.class.respond_to?(name)
          self.class.send(name, *args)
        else
          super
        end
      end

      def respond_to_missing?(name)
        self.class.respond_to?(name) || super
      end

      def to_json(*args)
        self.instance_variables.each_with_object({}) do |var, hash|
          hash[var.to_s.tr('@', '')] = self.instance_variable_get(var)
        end.to_json
      end

      class << self
        def request(body)
          configuration = Configuration.instance || Configuration.default_configuration
          raise(Five9::Client::Error, NOT_CONFIGURED_ERROR) unless configuration.present?
          request = Net::HTTP::Post.new configuration.url.path
          request.body = body
          request.content_type = 'text/xml'
          request.basic_auth(configuration.username, configuration.password)
          request['Accept-Encoding'] = 'gzip'
          request['SOAPAction'] = '""'
          http = Net::HTTP.new(configuration.url.host, configuration.url.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          response = http.request(request)
          begin
            Zlib::GzipReader.new(StringIO.new(response.body)).read
          rescue Zlib::Error
            response.body.tap do |result|
              if result.include?('<faultcode>') || result.include?('This request requires HTTP authentication')
                error_string = "Bad Five9 request sent. Response body was: #{result}, \nRequest body: #{body}"
                Five9::Client::Logger.error error_string
              end
            end
          end
        end

        def soap_envelope(action, parameters = {})
          xml = <<-XML
            <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:fn="http://service.admin.ws.five9.com/">
                <soapenv:Body>
                    <fn:#{action}>
                      #{self.serialize_parameters(parameters)}
                    </fn:#{action}>
                </soapenv:Body>
            </soapenv:Envelope>
          XML
          clean_up_array_tags(xml)
        end

        def serialize_parameters(parameters)
          parameters.to_xml.split(/<\/*hash>/).second.strip
        end

        def clean_up_array_tags(xml)
          xml.scan(ARRAY_TAG_REGEXP).each do |array_tag|
            tag = array_tag.strip.split('<').second.split.first
            xml = xml.gsub(/^\s*<\/?#{Regexp.quote(tag)}( type="array")?>\s*$/, '')
          end
          xml.gsub!('objectName', 'objectNames')
        end

        def response_hash(response, key, keys_to_dig_for = nil)
          keys_to_dig_for ||= ['Envelope', 'Body', key, 'return']
          Array.wrap(
            Hash.from_xml(response)
                .dig(*keys_to_dig_for)
          )
        end
      end
    end
  end
end
