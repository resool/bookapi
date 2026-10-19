module Staff
  module Errors
    class BaseError < StandardError
      def code
        self.class.name.demodulize.underscore
      end
    end
  end
end
