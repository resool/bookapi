module Staff
  class Error < StandardError
    def code
      self.class.name.demodulize.underscore
    end
  end
end
