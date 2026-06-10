module Api::V1::CompanyA
  class FmController < Api::V1::IntegrationsController

    def receive
      payload = parse_payload
      validate!(payload)
      processor.process(payload)
      render json: { success: true, message: "Webhook received" }, status: :ok
    rescue Common::Errors::AuthenticationError => e
      render json: { success: false, error: e.message }, status: :unauthorized
    rescue Common::Errors::ValidationError => e
      render json: { success: false, error: e.message }, status: :unprocessable_entity
    rescue Common::Errors::ServerError => e
      render json: { success: false, error: e.message }, status: :service_unavailable
    rescue StandardError => e
      render json: { success: false, error: "Internal error: #{e.message}" }, status: :internal_server_error
    end

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
