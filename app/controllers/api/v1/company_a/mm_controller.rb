module Api::V1::CompanyA
  class MmController < Api::V1::IntegrationsController
    private

    def utils
      CompanyA::Mm::Utils
    end

    def parse_payload
      body = request.body.read
      Hash.from_xml(body).values.first
    rescue StandardError
      raise Common::Errors::ValidationError, "Invalid XML payload"
    end

    def validate!(payload)
      data = payload.with_indifferent_access
      required = %w[event_type data]
      missing  = required.reject { |k| data.key?(k) }
      raise Common::Errors::ValidationError, "Missing fields: #{missing.join(', ')}" if missing.any?
    end

    def processor
      CompanyA::Mm::Processor.new
    end
  end
end
