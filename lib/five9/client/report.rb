# frozen_string_literal: true

module Five9
  module Client
    # This class is responsible for defining and running reports using Five9's API
    class Report
      def initialize(folder_name: 'T2', report_name: 'API')
        @folder_name = folder_name
        @report_name = report_name
      end

      def report_options(start_time, end_time, campaigns)
        {
          folderName: @folder_name,
          reportName: @report_name,
          criteria: {
            time: {
              start: self.format_date(start_time),
              end: self.format_date(end_time)
            },
            reportObjects: {
              objectNames: campaigns,
              objectType: 'Campaign'
            }
          }
        }
      end

      def format_date(date)
        date.strftime('%Y-%m-%dT%H:%M:%S.%L%:z')
      end

      def start(start_time, end_time, campaigns)
        response_hash(
          request(
            soap_envelope(:runReport, report_options(start_time, end_time, campaigns))
          ), 'runReportResponse'
        ).tap { |report_id| @five_nine_identifier = report_id }
      end

      def run(start_time:, end_time:, campaigns:)
        self.start(start_time, end_time, campaigns)
        return unless @five_nine_identifier.present?
        loop do
          sleep 5
          break unless self.running?
        end
        self.results.tap { @five_nine_identifier = nil }
      end

      def running?
        response_hash(
          request(
            soap_envelope(:isReportRunning, identifier: @five_nine_identifier)
          ), 'isReportRunningResponse'
        ).yield_self { |response| response == true || response.is_a?(String) && response.casecmp('true').zero? }
      end

      def results
        response_hash(
          request(
            soap_envelope(:getReportResult, identifier: @five_nine_identifier)
          ), 'getReportResultResponse'
        ).yield_self do |results|
          if results
            columns = results.dig('header', 'values', 'data')&.map do |header|
              header.gsub(/\s/, '_').gsub(/[()]/, '').downcase
            end

            records = results.dig('records')
            wrap_in_array(records).map do |record|
              record.dig('values', 'data')&.each_with_object({})&.with_index do |(value, record_hash), index|
                record_hash[columns[index]] = value.nil? || value.is_a?(Hash) ? nil : value
              end
            end
          end
        end
      end
    end
  end
end
