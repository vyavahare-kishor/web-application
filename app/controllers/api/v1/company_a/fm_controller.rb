module Api::V1::CompanyA
  class FmController < Api::V1::IntegrationsController
    private

    def utils
      CompanyA::Fm::Utils
    end

    def parse_payload
      JSON.parse(request.body.read)
    rescue JSON::ParserError
      raise Common::Errors::ValidationError, "Invalid JSON payload"
    end

    def validate!(payload)
      required = %w[event_type data]
      missing  = required.reject { |k| payload.key?(k) }
      raise Common::Errors::ValidationError, "Missing fields: #{missing.join(', ')}" if missing.any?
    end

    def processor
      CompanyA::Fm::Processor.new
    end
  end
end
