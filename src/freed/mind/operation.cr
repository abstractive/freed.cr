require "uuid"

module Freed
  class Mind
    module Operation

      def connect
        Gnosis.debug "Connecting"
        @socket = @context.socket(ZMQ::ROUTER)
        @socket.set_socket_option(ZMQ::LINGER, 0)
        @socket.bind(MIND_LOCATION)
        @poller.register_readable(@socket)
      end

      def online?(name : String)
        return unless @presences.has_key?(name)
        presence = @presences[name]
        return unless @thoughts.find { |address,thought|
          thought.presence.name == name && !thought.expired?
        }
        return presence
      end

      def start
        connect
        @running = true
        spawn do
          word = "Starting".colorize(:green).mode(:bold).to_s
          Gnosis.info "#{word} // #{MIND_LOCATION}", "0MQ"
          thinking
        end
        while @running
          sleep Protocol::Timing::WAIT
          CHANNEL.receive
        end
        word = "Stopping".colorize(:red).mode(:bold).to_s
        Gnosis.info "#{word} // #{MIND_LOCATION}", "0MQ"
      end

      def thinking
        critically do
          if @poller.poll(Protocol::Timing::POLL) != 0
            data = parse_messages!
            address = data.shift
            exists = @thoughts.has_key?(address)
            case command = data.shift
            when Protocol::Command::READY
              code = data.shift
              Gnosis.mark(" >", "R".colorize(:light_green))
              if exists
                thought_delete(address)
              else
                thought_attach(address, code)
              end
            when Protocol::Command::REPLY
              Gnosis.mark(" >", "R".colorize(:light_cyan))
              code = data.shift
              uuid = data.shift
              unless presence = @presences[code]?
                raise Error::Presence::Unavailable.new(code)
              end
              thought_idle(address)
              presence.response!(uuid, data.shift)
              Gnosis.mark(" >", "R".colorize(:light_cyan))
            when Protocol::Command::HEARTBEAT
              Gnosis.mark(" >", "H".colorize(:light_magenta))
              if exists
                thought_fetch(address).reset_expiration
              else
                thought_disconnect(address)
              end
            when Protocol::Command::DISCONNECT
              Gnosis.mark(" >", "D".colorize(:light_red))
              thought_delete(address) if exists
            else
              raise Error::Invalid::CommandReceived.new(command)
            end
          else
            CHANNEL.send(nil)
          end
          if next_heartbeat?
            @waiting.each do |thought|
              if thought.expired?
                Gnosis.debug("Cannon expired: #{thought.pretty}")
                Gnosis.mark(" x", "C".colorize(:red))
                thought_delete(thought)
              else
                send(thought, Protocol::Command::HEARTBEAT)
                Gnosis.mark(" <", "H".colorize(:magenta))
              end
            end
            reset_heartbeat
          end
          if @presences.any?
            @presences.each { |code, presence|
              dispatch(presence)
            }
          end
          CHANNEL.send(nil)
        end
      end

      def critically
        while(@running)
          begin
            yield
          rescue ex
            Gnosis.exception(ex)
            reset
          end
        end
        shutdown
      end
      
      def target(presence : Presence, json : String)
        uuid = UUID.random.to_s
        presence.requests.push({uuid: uuid, json: json})
          Gnosis.mark(" *", "T".colorize(:light_yellow))
        return uuid
      end

      private def dispatch(presence : Presence)
        while presence.idle.any? && presence.requests.any?
          message = presence.requests.shift
          thought = presence.idle.shift
          @waiting.delete(thought)
          Gnosis.mark(" *", "D".colorize(:yellow))
          send(thought, Protocol::Command::REQUEST, message[:uuid], message[:json])
        end
      end

      private def send(
                        thought : Cannon | String,
                        command : String,
                        option : String? = nil,
                        message : String | Array(String) | Nil = Array(String).new
                      )
        thought = thought.address if thought.is_a?(Cannon)
        message = [message] if message.is_a?(String)
        message.unshift(option) if option
        message.unshift(command)
        message.unshift(Protocol::HEADER)
        message.unshift("")
        message.unshift(thought)
        @socket.send_strings(message)
      end

      private def parse_messages!
        data = @socket.receive_strings
        #de Leave the address in index 0.
        data.delete_at(1)
        header = data.delete_at(1)
        unless header == Protocol::HEADER
          raise Error::Invalid::ProtocolVersion.new(header)
        end
        #de debug("Remaining message: #{data.inspect.colorize(:yellow)}")
        return data
      end

      def shutdown
        if @socket && !@socket.closed?
          @socket.close
          @poller.deregister_readable(@socket)
        end
      rescue
      end

    end
  end
end
