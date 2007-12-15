module Amazon
  module SDS
    class ResultSet
      include Enumerable
      attr_reader :items
      
      def initialize(items, more_token = nil)
        @items = items
        @more_token = more_token
      end
      
      def more_items?
        not @more_token.nil?
      end
      
      def keys
        @items.map {|i| i.key }
      end
      
      def each
        @items.each do |i|
          yield i
        end
      end
    end
  end
end