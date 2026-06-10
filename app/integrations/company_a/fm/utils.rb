module CompanyA::Fm
  class Utils < Common::Utils
    def self.authenticate!(token:)
      expected = ENV.fetch("JSON_WEBHOOK_AUTH_KEY") do
        raise Common::Errors::ServerError, "JSON_WEBHOOK_AUTH_KEY is not configured"
      end

      unless token == expected
        raise Common::Errors::AuthenticationError, "Invalid authentication token for FM account"
      end

      true
    end
  end
end
