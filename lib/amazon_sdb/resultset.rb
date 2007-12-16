module Amazon
  module SDS
    
    ##
    # Represents a ResultSet returned from Domain#query. Currently, this is just
    # a set of Items plus an operation to see if there is another set to be retrieved
    # and to load it on demand. When Amazon sees fit to add total results or other metadata
    # for queries that will also be included here.
    class ResultSet
      include Enumerable
      attr_reader :items
      
      def initialize(domain, items, more_token = nil)
        @domain = domain
        @items = items
        @more_token = more_token
      end
      
      ##
      # Returns true if there is another result set to be loaded
      def more_items?
        not @more_token.nil?
      end
      
      ##
      # Not implemented yet
      def load_next!
      end
      
      ##
      # Iterator through all the keys in this resultset
      def keys
        @items.map {|i| i.key }
      end
      
      ##
      # Support method for Enumerable. Iterates through the items in this set (NOT all the matching results for a query)
      def each
        @items.each do |i|
          yield i
        end
      end
    end
  end
end