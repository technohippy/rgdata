module RGData
  module Util
    class ArrayWithDelegationToFirst < Array
      undef type

      def self.from_array(array)
        self.new array
      end

      def method_missing(name, *args, &block)
        self[0].__send__ name, *args, &block
      end
    end
  end
end
