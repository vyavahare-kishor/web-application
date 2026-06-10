module CompanyA::Mm
  class Utils < Common::Utils
    def self.authenticate!(token:)
      expected = ENV.fetch("XML_WEBHOOK_AUTH_KEY") do
        raise Common::Errors::ServerError, "XML_WEBHOOK_AUTH_KEY is not configured"
      end

      unless token == expected
        raise Common::Errors::AuthenticationError, "Invalid authentication token for MM account"
      end

      true
    end
  end
end
