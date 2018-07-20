# frozen_string_literal: true

module Five9
  module Client
    # This class is responsible for delegating logging out to
    # any handlers that the application wants to provide to
    # receive notification of errors, warnings, etc.
    class Logger
      include Singleton

      @handlers = []

      class << self
        def register_handler(handler_receiver, method_aliases = {})
          @handlers << {
            receiver: handler_receiver,
            aliases: method_aliases
          }
        end

        def error(message)
          @handlers.each do |handler|
            receiver = handler[:receiver]
            aliases = handler[:aliases]
            receiver.send(aliases[:error] || :error, message)
          end
        end
      end
    end
  end
end
