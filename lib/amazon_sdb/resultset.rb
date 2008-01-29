require 'delegate'

module Amazon
  module SDB
    
    ##
    # Represents a ResultSet returned from Domain#query. Currently, this is just
    # a set of Items plus an operation to see if there is another set to be retrieved
    # and to load it on demand. When Amazon sees fit to add total results or other metadata
    # for queries that will also be included here.
    class ResultSet < DelegateClass(Array)
      attr_reader :items
      
      def initialize(domain, items, next_token = nil)
        @domain = domain
        @items = items
        super(@items)
        @next_token = next_token
      end
           
      ##
      # Returns true if there is another result set to be loaded
      def more_items?
        not @more_token.nil?
      end
      
      ##
      # Not implemented yet
      def load_next!
        if @more_token.nil?
          @items = []
        else
          @items = @domain.query(:next_token => @next_token)
        end
      end
      
      ##
      # Iterator through all the keys in this resultset
      def keys
        @items.map {|i| i.key }
      end
    end
  end
end