module Freed  
  class Mind
    class Thought
      property presence : Presence
      property expiry : Time::Span
      getter address

      def initialize(@address : String, @presence : Presence)
        @expiry = reset_expiration
      end

      def expired?
        @expiry <= Time.monotonic
      end

      def pretty
        "[#{@presence.name.colorize(:green)}:#{@address.inspect}]"
      end

      def reset_expiration
        #de debug("Resetting expiration: #{pretty}")
        @expiry = Time.monotonic + Protocol::Timing::EXPIRES
      end

      module Methods

        private def thought_fetch(address : String)
          @thoughts[address]
        end

        private def thought_attach(address : String, presence : Presence | String)
          presence = presence_require(presence)
          @thoughts[address] ||= Thought.new(address, presence)
          thought_idle(address)
        end

        private def thought_delete(cannon : Thought | String)
          cannon = @thoughts[cannon] if cannon.is_a?(String)
          thought_disconnect(cannon)
          cannon.presence.idle.delete(cannon) if cannon.presence
          @waiting.delete(cannon)
          @thoughts.delete(cannon.address)
        end

        def thought_idle(cannon : Thought | String)
          cannon = @thoughts[cannon] if cannon.is_a?(String)
          @waiting << cannon
          cannon.presence.idle.push cannon
          cannon.reset_expiration
          dispatch(cannon.presence)
        end

        def thought_disconnect(cannon : Thought | String)
          send(cannon, Protocol::Command::DISCONNECT)
        end

      end
    end
  end
end
