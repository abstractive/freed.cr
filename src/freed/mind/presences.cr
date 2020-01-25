module Freed
  class Mind
    class Presence
      include Coincide
      property requests
      property idle
      getter name

      def initialize(@name : String)
        @requests = [] of { uuid: String, json: String}
        @idle = [] of Cannon
        @responses = Hash(String, String).new
        Gnosis.debug("Initialized #{@name}")
        @timers = Hash(String, Time::Span).new
      end

      def response!(uuid, json)
        @responses[uuid] = json
      end

      def await?(uuid : String)
        @timers[uuid] = Time.monotonic + Protocol::Timing::REPLY
        loop do
          if reply = @responses.delete(uuid)
            @timers.delete(uuid)
            return reply
          end
          if @timers[uuid] < Time.monotonic
            #de TODO: Remove from request queue also
            @timers.delete(uuid)
            return
          end
          sleep Protocol::Timing::WAIT
          CHANNEL.send(nil)
        end
      end

      module Methods

        private def presence_require(name)
          @presences[name] ||= Presence.new(name)
        end

      end
    end
  end
end
