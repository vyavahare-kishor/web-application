module Integrations::Yeeter::Deliverator
  class Utils < Common::Utils
    def self.authenticate!(token:)
      raise NotImplementedError, "Authentication logic not implemented for Deliverator integration"
    end
  end
end
