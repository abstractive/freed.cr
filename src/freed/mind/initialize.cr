module Freed
  class Mind
    module Initialize

      DEFAULTS = {
        "mongo" => {
          "host" => "127.0.0.1",
          "port" => 27017,
          "database" => "test"
        },
        "credentials" => {
          "mongo" => {
            "username" => nil,
            "password" => nil
          }
        },
        "zeromq" => {
          "host" => "127.0.0.1",
          "port" => 12601,
          "threads" => {
            "mind" => 4
          }
        }
      }

      ENVIRONMENT = ENV["ENVIRONMENT"] ||= "coding"
      CALLSITE = (ENV["FREED_CALLSITE"] ||= FileUtils.pwd).chomp

      FILE_CONFIGURATION = "config/environments/#{ENVIRONMENT}/freed.yml"
      FILE_SECRETS = ENV["FREED_SECRETS"] ||= "secrets.yml"

      def configure
        configuration = Totem.new(
          config_envs: ["coding", "stage", "live"],
          config_type: "yaml"
        )

        configuration.set_defaults(DEFAULTS)
        
        File.open("#{CALLSITE}/#{FILE_CONFIGURATION}") do |io|
          configuration.parse(io)
        end

        File.open("#{CALLSITE}/#{FILE_SECRETS}") do |io|
          configuration.parse(io)
        end

        configuration
      end

    end
  end
end
