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

    def self.parse(request)
      JSON.parse(request.body.read).with_indifferent_access
    rescue JSON::ParserError => e
      raise Common::Errors::ValidationError, "Invalid JSON: #{e.message}"
    end

    def self.validate!(payload)
      missing = %w[event_type data].reject { |f| payload.key?(f) }
      raise Common::Errors::ValidationError, "Missing fields: #{missing.join(', ')}" if missing.any?
    end
  end
end
