require "./initialize"
require "file_utils"
require "totem"
require "mongo"         #de Expect MongoDB right now and make no effort to abstract it.
require "./mongo/*"
require "uuid"
require "./protocol"

require "./mind/initialize"
require "./mind/operation"
require "./mind/presences"
require "./mind/thoughts"

module Freed
  class Mind

    include Mongo::Connecting
    include Mongo::Accessing

    include Thought::Methods
    include Presence::Methods

    include Initialize
    include Operation

    property database : ::Mongo::Database
    property client : ::Mongo::Client

    property context : ZMQ::Context
    property poller : ZMQ::Poller

    property presences : Hash(String, Presence)
    property thoughts : Hash(String, Thought)
    property waiting : Array(Thought)

    @socket = uninitialized ZMQ::Socket

    getter configuration : Totem::Config

    def initialize
      @configuration = configure
      @client = establish_connection
      @database = attach_database

      @context = ZMQ::Context.new(@configuration["zeromq.threads.mind"].as_i)
      @poller = ZMQ::Poller.new
      @thoughts = Hash(String, Thought).new
      @presences = Hash(String, Presence).new
      @waiting = Array(Thought).new
    end
  end
end
