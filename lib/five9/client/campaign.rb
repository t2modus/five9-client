# frozen_string_literal: true

module Five9
  module Client
    # This class is responsible for logic for retrieving and
    # represenging Five9 call campaigns
    class Campaign < Base
      APPROVED_ATTRIBUTES = %w[name description mode profile_name state type].freeze

      self.attr_accessor(*APPROVED_ATTRIBUTES)

      def initialize(attributes)
        attributes.with_indifferent_access.slice(*APPROVED_ATTRIBUTES.map { |a| a.camelize(:lower) }).each do |k, v|
          self.send("#{k.underscore}=", v)
        end
      end

      def request_options
        { campaignName: self.name }
      end

      def campaign_instance_request(action)
        response_hash(
          request(
            soap_envelope(action, self.request_options)
          ), "#{action}Response"
        )
      end

      ##### Instance Methods for Campaign #####

      def phone_numbers
        self.campaign_instance_request('getCampaignDNISList')
      end

      %i[stop start reset].each do |action|
        define_method action do
          self.campaign_instance_request("#{action}Campaign")
        end
      end

      ##### Association Methods #####
      def lists
        return @lists if @lists.present?
        response = self.campaign_instance_request('getListsForCampaign')
        response = [response] if response.is_a?(Hash)
        @lists = response.map(&List.method(:new))
      end

      def create_list(list_name)
        @lists ||= []
        List.create(list_name).tap do |list|
          list.add_to_campaign(self.name)
          @lists << list
        end
      end

      def ai_list
        start_date = Time.now.strftime('%b %d %Y %H-%M-%S')
        "#{self.name} #{start_date}".tap do |list_name|
          unless self.lists.any? { |list| list.name == list_name }
            self.lists.min_by(&:upload_time).remove_from_campaign(self.name) if self.lists.count > 8
            self.create_list(list_name)
          end
        end
      end

      class << self
        def list(campaign_name_pattern = nil)
          request_options = { campaignNamePattern: campaign_name_pattern }.compact
          response_hash(
            request(
              soap_envelope(:getCampaigns, request_options)
            ), 'getCampaignsResponse'
          ).map(&method(:new))
        end

        # Gets all phone numbers associated with a given campaign.
        # The campaign MUST be an inbound campaign, or this method will throw an exception.
        def get_phone_numbers(campaign_name)
          self.new(name: campaign_name).phone_numbers
        end

        %i[stop start reset].each do |action|
          define_method action do |name|
            self.new(name: name).send(action)
          end
        end
      end
    end
  end
end
