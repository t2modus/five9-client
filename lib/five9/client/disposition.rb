# frozen_string_literal: true

module Five9
  module Client
    # This class is responsible for retrieving disposition information from Five9
    class Disposition < Base
      APPROVED_ATTRIBUTES = %w[agent_full_name appointment call_id call_end_timestamp call_number
                               call_type_name campaign_name comments customer_id dealership_id
                               disposition_name lead_id].freeze
      self.attr_accessor(*APPROVED_ATTRIBUTES)

      def initialize(attributes)
        attributes.slice(*APPROVED_ATTRIBUTES.map(&:camelize)).each do |k, v|
          self.send("#{k}=", v)
        end
      end

      class << self
        def list(start_time:, end_time:, campaigns:)
          Report.new.run(start_time: start_time, end_time: end_time, campaigns: campaigns).map(&method(:new))
        end
      end
    end
  end
end
