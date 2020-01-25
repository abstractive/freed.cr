module Freed
  class Mind
    module Mongo
      module Connecting

        private def connection_credentials
          string = [] of String
          if (username = @configuration["credentials.mongo.username"]?) && username.as_s?
            string << username.to_s
            if (password = @configuration["credentials.mongo.password"]?) && password.as_s?
              string << password.to_s
            end
          end
          return "" if string.empty?
          "#{string.join(":")}@"
        end

        private def connection_location
          string = [] of String
          if (host = @configuration["mongo.host"]?) && host.as_s?
            string << host.to_s
            if (port = @configuration["mongo.port"]?) && port.as_s?
              string << port.to_s
            end
          end
          string.join(":")
        end

        private def connection_database
          if (database = @configuration["mongo.database"]?) && database.as_s?
            return database.as_s
          end
          raise Error::Missing::Database.new
        end

        private def connection_endpoint
          "mongodb://#{connection_credentials}#{connection_location}/#{connection_database}"
        end

        def database_connection
          ::Mongo::Client.new(connection_endpoint)
        end

      end
    end
  end
end
