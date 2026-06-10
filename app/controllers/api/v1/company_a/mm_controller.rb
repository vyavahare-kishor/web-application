module Api::V1::CompanyA
  class MmController < Api::V1::IntegrationsController

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
