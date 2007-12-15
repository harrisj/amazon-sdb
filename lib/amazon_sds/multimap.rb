module Amazon
  module SDS
    ##
    # A multimap is like a hash or set, but it only requires that key/value pair is unique (the same key may have multiple values)
    class Multimap
      include Enumerable
      
      def self.numeric(float, size, precision)
        sprintf "%0#{size}.#{precision}f", float
      end
      
      def initialize(init=nil)
        @mset = {}

        clear_size!

        if init.nil?
          # do nothing
        elsif init.is_a? Hash
          init.each {|k, v| put(k, v) }
        elsif init.is_a? Array
          # load from array
          if init.any? {|v| ! v.is_a? Array || v.size != 2 }
            raise ArgumentError, "Array must be of key/value pairs only"
          end

          init.each {|v| self.put(v[0], v[1])}
        elsif init.is_a? Multimap
          @mset = init.mset.dup
        else
          raise ArgumentError, "Wrong type passed as initializer"
        end
      end

      def clear_size!
        @size = nil
      end
      
      def size
        if @size.nil?
          @size = @mset.inject(0) do |total, pair|
            value = pair[1]
            if value.is_a? Array
              total + value.size
            else
              total + 1
            end
          end
        end

        @size
      end

      def put(key_arg, value, options = {})
        key = key_arg.to_s

        if options[:before_cast]
          key = "#{key}_before_cast"
        end

        k = @mset[key]
        clear_size!

        if k.nil? || options[:replace]
          @mset[key] = value
        else
          @mset[key] = @mset[key].to_a + [value]
        end
      end
      
      ##
      # Returns all the values that match a key. Normally, if there is only a single value entry 
      # returns just the value, with an array for multiple values, and nil for no match. If you want
      # to always return an array, pass in <tt>:force_array => true</tt> in the options
      def get(key_arg, options = {})
        key = key_arg.to_s

        if options[:before_cast]
          key = "#{key}_before_cast"
        end

        k = @mset[key]

        if options[:force_array]
          return [] if k.nil?
          k.to_a
        else
          k
        end
      end

      def [](key)
        get(key)
      end
      
      def []=(key, value)
        put(key, value, :replace => true)
      end

      def each
        @mset.each_pair do |key, group| 
          group.to_a.each do |value|
            yield [key, value]
          end
        end    
      end

      def each_pair
        @mset.each_pair do |key, group|
          case group
          when Array 
            group.each do |value|
              yield key, value
            end
          else
            yield key, group
          end
        end
      end

      def each_pair_with_index(&block)
        index = 0
        self.each_pair do |key, value|
          yield key, value, index
          index += 1
        end
      end

      def string_escape(str)
        str.gsub("\\", "\\\\").gsub("'", "\\'")
      end
      
      def sds_key_escape(key)
        case key
        when String
          string_escape(key)
        else
          key.to_s
        end
      end

      def sds_value_escape(value)
        case value
        when Fixnum
          sprintf("%0#{Base.number_padding}d", value)
        when Float
          numeric(value, Base.number_padding, Base.float_precision)
        when String
          string_escape(value)
        when Time
          value.iso8601
        else
          value.to_s
        end
      end

      def to_sds
        out = {}
        self.each_pair_with_index do |key, value, index|
          out["Name#{index}"] = sds_key_escape(key)
          out["Value#{index}"] = sds_value_escape(value)
        end

        out
      end

      # def self.integer(*params)
      #   params.each do |p|
      #     integer_fields[p.to_s] = 1
      #   end
      # end
      # 
      # def self.float(*params)
      #   params.each do |p|
      #     float_fields[p.to_s] = 1
      #   end
      # end
      # 
      # def self.datetime(*params)
      #   params.each do |p|
      #     datetime_fields[p.to_s] = 1
      #   end
      # end

      def coerce(value)
        case value
        when /^0+\d+$/
          value.to_i
        when /^0+\d*.\d+$/
          value.to_f
        when /^\d{4}-\d{2}-\d{2}(T\d{2}:\d{2}:\d{2}([+\-]\d{2}:\d{2})?)?$/
          Time.parse(value)
        else
          value
        end
      end
      
      def from_sds(values)
        @mset = {}
        clear_size!

        if values.nil?
          # do nothing
        elsif values.is_a? Array
          # load from array
          if values.any? {|v| ! v.is_a? Array || v.size != 2 }
            raise ArgumentError, "Array must be of key/value pairs only"
          end

          values.each do |v|
            self.put(v[0], v[1], :before_cast => true)
            self.put(v[0], coerce(v[1]))
          end
        else
          raise ArgumentError, "Wrong type passed as initializer"
        end
      end
      
      def method_missing(method_symbol, *args)
        name = method_symbol.to_s
        if name =~ /^\w+$/
          if @mset.key? name
            get(name)
          else
            super
          end
        else
          super
        end
      end
    end
  end
end