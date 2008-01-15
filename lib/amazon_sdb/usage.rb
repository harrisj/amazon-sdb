module Amazon
  module SDB
    ##
    # A class for accumulating usage data returned from Amazon requests. Returned by Base#usage
    class Usage
      attr_reader :box_usage
      
      def initialize
        reset!
      end
      
      def add_usage(value)
        @box_usage += value
      end
      
      def reset!
        @box_usage = 0.0
      end
      
      def <<(value)
        @box_usage += value
      end
    end
  end
end