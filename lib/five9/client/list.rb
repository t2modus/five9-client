# frozen_string_literal: true

# Requiring rails' date helper libraries since they get sed a bit for the AI list creation
require 'active_support/core_ext/numeric/time'

module Five9
  module Client
    # This class is responsible for logic for retrieving and
    # represenging Five9 call campaigns
    class List < Base
      self.attr_accessor :name

      def initialize(attributes)
        self.name = attributes['name'] || attributes['listName']
      end

      def header_columns(fields)
        header_columns = fields.map.with_index do |field, index|
          <<~XML
            <fieldsMapping>
              <columnNumber>#{index}</columnNumber>
              <fieldName>#{field}</fieldName>
              <key>#{index.zero?}</key>
            </fieldsMapping>
          XML
        end
        header_columns.join("\n")
      end

      def add_records(records)
        fields = records.first.keys
        xml_string = <<~XML
          <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:fn="http://service.admin.ws.five9.com/">
            <soapenv:Body>
              <fn:addToListCsv>
                <listName>#{self.name}</listName>
                <listUpdateSettings>
                  #{self.header_columns}
                  <reportEmail>admin@t2modus.com</reportEmail>
                  <separator>,</separator>
                  <skipHeaderLine>true</skipHeaderLine>
                  <cleanListBeforeUpdate>true</cleanListBeforeUpdate>
                  <crmAddMode>ADD_NEW</crmAddMode>
                  <crmUpdateMode>UPDATE_ALL</crmUpdateMode>
                  <listAddMode>ADD_ALL</listAddMode>
                </listUpdateSettings>
                <csvData>#{fields.join(',')}
                  #{records.map { |r| r.values.join(',') }.join("\n")}
                </csvData>
              </fn:addToListCsv>
            </soapenv:Body>
          </soapenv:Envelope>
        XML
        response_hash(request(xml_string), 'addToListCsvResponse')
      end

      def add_to_campaign(campaign_name)
        response_hash(
          request(
            soap_envelope(:addListsToCampaign, campaignName: campaign_name, lists: { listName: self.name })
          ), 'addListsToCampaignResponse'
        )
      end

      def remove_from_campaign(campaign_name)
        response_hash(
          request(
            soap_envelope(:removeListsFromCampaign, campaignName: campaign_name, lists: [{ listName: self.name }])
          ), 'removeListsFromCampaignResponse'
        )
      end

      def upload_time
        Time.strptime(self.name.split.last(4).join(' '), ' %b %d %Y %H-%M-%S')
      rescue ArgumentError # if format is incorrect
        (52 * 10).weeks.from_now # I couldn't find where the .years method is defined, so I used this as a workaround
      end

      class << self
        def add_records_to(list_name)
          self.new(name: list_name).add_records
        end

        def create(list_name)
          self.new response_hash(request(soap_envelope(:createList), listName: list_name), 'CreateListResponse')
        end

        def for_campaign(campaign_name)
          Campaign.new(name: campaign_name).lists
        end
      end
    end
  end
end
