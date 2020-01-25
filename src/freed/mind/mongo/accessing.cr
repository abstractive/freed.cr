module Freed
  class Mind
    module Mongo
      module Accessing

        private def attach_database
          @client[connection_database]
        end

        def [](key : String)
          @database[key]
        end

      end
    end
  end
end
