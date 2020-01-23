require "file_utils"

module Freed

  class Mind

    include Mongo::Connecting
    include Mongo::Accessing

    MONGO_DEFAULTS = {
      "mongo" => {
        "host"     => "localhost",
        "port"     => 27017,
        "database" => "test",
        "username" => nil,
        "password" => nil
      }
    }

    ENVIRONMENT = ENV["FREED_ENVIRONMENT"] ||= "coding"
    CALLSITE = (ENV["FREED_CALLSITE"] ||= FileUtils.pwd).chomp

    FILE_CONFIGURATION = (ENV["FREED_CONFIGURATION"]? && File.exists?(ENV["FREED_CONFIGURATION"])) ? ENV["FREED_CONFIGURATION"] : "freed.yml"
    FILE_SECRETS = ENV["FREED_SECRETS"] ||= "secrets.yml"

    property database : ::Mongo::Database
    property client : ::Mongo::Client

    getter configuration

    def initialize
      @configuration = Totem.new(
        config_envs: ["coding", "stage", "live"],
        config_type: "yaml"
      )

      @configuration.set_defaults(MONGO_DEFAULTS)
      
      File.open("#{CALLSITE}/#{FILE_CONFIGURATION}") do |io|
        @configuration.parse(io)
      end

      File.open("#{CALLSITE}/#{FILE_SECRETS}") do |io|
        @configuration.parse(io)
      end

      @client = establish_connection
      @database = attach_database

    end
  end
end
