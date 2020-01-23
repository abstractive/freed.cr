module Freed
  module Mongo
    module Accessing

      def attach_database
        @client[connection_database]
      end

      def [](key : String)
        @database[key]
      end

    end
  end
end
