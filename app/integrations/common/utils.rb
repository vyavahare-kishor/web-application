module Common
  class Utils
    def self.authenticate!(token:)
      raise NotImplementedError, "Authentication logic must be implemented in subclass"
    end
  end
end
