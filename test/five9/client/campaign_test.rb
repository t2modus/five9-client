# frozen_string_literal: true

require 'test_helper'

module Five9
  module Client
    class CampaignTest < Minitest::Test
      def test_should_be_able_to_get_a_list_of_campaigns_from_five9
        setup_configuration(url: 'http://five9.com/path')
        stub_action(:getCampaigns, webmock_file(:campaigns))
        campaigns = Five9::Client::Campaign.list
        campaigns.each { |c| assert c.is_a?(Five9::Client::Campaign) }
        assert_equal 384, campaigns.count
      end

      def test_should_be_able_to_limit_search_by_campaign_name
        setup_configuration(url: 'http://five9.com/path')
        stub_action(:getCampaigns, webmock_file('toyota-campaigns'))
        campaigns = Five9::Client::Campaign.list('Toyota*')
        campaigns.each { |c| assert c.is_a?(Five9::Client::Campaign) }
        assert_equal 6, campaigns.count
      end

      def test_should_be_able_to_get_an_inbound_campaigns_phone_number
        setup_configuration(url: 'http://five9.com/path')
        campaign = Five9::Client::Campaign.new(name: 'Test Campaign')
        stub_action(:getCampaignDNISListResponse, webmock_file('campaign-phone-number'))
        assert_equal ['4324668913'], campaign.phone_numbers
      end

      def test_should_be_able_to_stop_a_campaign
        setup_configuration(url: 'http://five9.com/path')
        campaign = Five9::Client::Campaign.new(name: 'Test Campaign')
        stub_action(:stopCampaign, webmock_file('stop-campaign'))
        assert_equal ['Success!'], campaign.stop
      end

      def test_should_be_able_to_start_a_campaign
        setup_configuration(url: 'http://five9.com/path')
        campaign = Five9::Client::Campaign.new(name: 'Test Campaign')
        stub_action(:startCampaign, webmock_file('start-campaign'))
        assert_equal ['Success!'], campaign.start
      end

      def test_should_be_able_to_reset_a_campaign
        setup_configuration(url: 'http://five9.com/path')
        campaign = Five9::Client::Campaign.new(name: 'Test Campaign')
        stub_action(:resetCampaign, webmock_file('reset-campaign'))
        assert_equal ['Success!'], campaign.reset
      end

      def test_should_be_able_to_get_associated_lists
        setup_configuration(url: 'http://five9.com/path')
        campaign = Five9::Client::Campaign.new(name: 'Test Campaign')
        stub_action(:getListsForCampaign, webmock_file('lists-for-campaign'))
        assert_equal [Five9::Client::List.new(name: 'Millennium Honda_2017-10-04_PL_AR')].to_json, campaign.lists.to_json
      end

      def test_should_be_able_to_create_new_associated_lists
        list = List.new(name: 'Test List')
        List.stubs(:create).returns(list)
        list.expects(:add_to_campaign).with('Test Campaign').once
        campaign = Campaign.new(name: 'Test Campaign')
        campaign.create_list(list.name)
        assert_equal [list], campaign.instance_variable_get('@lists')
      end

      def test_should_not_create_ai_list_if_one_already_exists_for_given_time
        setup_configuration(url: 'http://five9.com/path')
        campaign = Campaign.new(name: 'Test Campaign')
        Timecop.freeze
        begin
          date_string = Time.now.strftime('%b %d %Y %H-%M-%S')
          # if we have an AI list already for this time we shouldn't create a new one
          current_list = List.new(name: "Test List #{date_string}")
          campaign.stubs(:lists).returns([current_list])
          campaign.expects(:create_list).never
        ensure
          Timecop.return
        end
      end

      def test_ai_list_should_delete_oldest_list_if_there_are_too_many
        setup_configuration(url: 'http://five9.com/path')
        campaign = Campaign.new(name: 'Test Campaign')
        Timecop.freeze
        lists = 9.times.map { |n| List.new(name: "Test List #{n.days.ago.strftime('%b %d %Y %H-%M-%S')}") }
        begin
          lists.last.expects(:remove_from_campaign).with('Test Campaign').once
          campaign.expects(:create_list).once
          campaign.stubs(:lists).returns(lists)
          campaign.ai_list
        ensure
          Timecop.return
        end
      end
    end
  end
end
