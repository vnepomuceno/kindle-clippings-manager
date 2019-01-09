module KindleClippings
  module Support
    module MongoConnection
      @connection = nil

      def self.get
        @connection = init_connection if @connection.nil?
        @connection
      end

      def self.init_connection
        db_url = ENV['MONGO_DB_URL']
        raise 'MongoDB URL not configured' if db_url.nil?

        Mongo::Client.new(db_url)
      end
      private_class_method :init_connection

      def self.close_connection
        @connection.close
      end
    end
  end
end
