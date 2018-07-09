# frozen_string_literal: true

module Five9
  module Client
    # This class is the base class containing all logic common to all
    # Five9 API classes
    class Base
      ARRAY_TAG_REGEXP = /^\s*<[a-zA-Z]+ type="array">/

      def initialize(configuration = nil)
        @configuration = configuration || Configuration.default_configuration
      end

      class << self
        def wrap_in_array(response)
          return [] if response.nil?
          response = [response] unless response.is_a?(Array)
          response
        end

        def request(body)
          request = Net::HTTP::Post.new @configuration.url.path
          request.body = body
          request.content_type = 'text/xml'
          request.basic_auth(*@configuration.login.auth_args)
          request['Accept-Encoding'] = 'gzip'
          request['SOAPAction'] = '""'
          http = Net::HTTP.new(@configuation.url.host, @configuration.url.port)
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
            xml.gsub!(/^\s*<\/?#{Regexp.quote(tag)}( type="array")?>\s*$/, '')
          end
          xml
        end

        def response_hash(response, key)
          wrap_in_array(
            Hash.from_xml(response)
                .dig('Envelope', 'Body', key, 'return')
          )
        end
      end
    end
  end
end
