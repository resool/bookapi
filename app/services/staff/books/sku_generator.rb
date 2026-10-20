module Staff
  module Books
    class SkuGenerator
      DIGITS = 6

      # :reek:UtilityFunction
      def call
        SecureRandom.random_number(10**DIGITS).to_s.rjust(DIGITS, "0")
      end
    end
  end
end
