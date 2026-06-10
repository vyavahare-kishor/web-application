module Common
  class Utils
    def self.authenticate!(token:)
      raise NotImplementedError, "Authentication logic must be implemented in subclass"
    end

    def self.parse(request)
      raise NotImplementedError, "parse must be implemented"
    end

    def self.validate!(payload)
      raise NotImplementedError, "validate! must be implemented"
    end
  end
end
