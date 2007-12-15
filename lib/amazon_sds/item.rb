module Amazon
  module SDS
    ##
    # An item from SDS. This basically is a key for the item in the domain and a Multimap of the attributes. You should never
    # call Item#new, instead it is returned by various methods in Domain and ResultSet
    class Item
      include Enumerable
      attr_accessor :key, :attributes
      
      def initialize(domain, key, multimap=nil)
        @domain = domain
        @key = key
        @attributes = multimap
      end
      
      def reload!
        item = @domain.get_attributes(@key)
        @attributes = item.attributes
      end
      
      def destroy!
        @domain.delete_attributes(@key)
      end
      
      def save
        @domain.put_attributes(@key, @attributes)
      end
      
      def get(key)
        reload! if @attributes.nil?
        @attributes.get(key)
      end
      
      def [](key)
        get(key)
      end
      
      def each
        @attributes.each
      end
      
      def each_pair
        @attributes.each_pair
      end
    end
  end
end