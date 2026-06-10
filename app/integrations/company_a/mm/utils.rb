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

    def self.parse(request)
      body = request.body.read
      raise Common::Errors::ValidationError, "Empty payload" if body.blank?
      Hash.from_xml(body).values.first.with_indifferent_access
    rescue REXML::ParseException => e
      raise Common::Errors::ValidationError, "Invalid XML: #{e.message}"
    end

    def self.validate!(payload)
      missing = %w[event_type data].reject { |f| payload.key?(f) }
      raise Common::Errors::ValidationError, "Missing fields: #{missing.join(', ')}" if missing.any?
    end
  end
end
