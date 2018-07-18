# frozen_string_literal: true

module Five9
  module Client
    class ListTest < Minitest::Test

      # I'm not going to bother testing add_records because
      # 1) I don't have an easy way to get sample response XML without actually
      #    making prod requests that will result in calls being made, and
      # 2) It'll be pretty obvious pretty quickly if something goes wrong with it, and
      # 3) I literally lifted this code from the reporting tool, where it's been
      #    happily working for months.
      # Everything else from the list class should be tested here.

      def test_add_to_campaign
        setup_configuration(url: 'http://five9.com/path')
        stub_action(:addListsToCampaign, webmock_file('add-list-to-campaign'))
        assert_equal([], List.new(name: 'Test List').add_to_campaign('Test Campaign'))
      end

      def test_remove_from_campaign
        setup_configuration(url: 'http://five9.com/path')
        stub_action(:removeListsFromCampaign, webmock_file('remove-list-from-campaign'))
        assert_equal [], List.new(name: 'Test List').remove_from_campaign('Test Campaign')
      end

      def test_upload_time
        Timecop.freeze
        begin
          date_string = 1.day.ago.strftime('%b %d %Y %H-%M-%S')
          assert_equal 1.day.ago.inspect, List.new(name: date_string).upload_time.inspect
        ensure
          Timecop.return
        end
      end

      def test_create
        setup_configuration(url: 'http://five9.com/path')
        stub_action(:createList, webmock_file('create-list'))
        assert_equal List.new(name: 'Test').to_json, List.create('Test').to_json
      end
    end
  end
end
