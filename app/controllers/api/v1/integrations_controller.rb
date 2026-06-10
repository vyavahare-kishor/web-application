module Api::V1
  class IntegrationsController < ApplicationController
    include Common::Concerns::AuthenticatedIntegration

    before_action :authenticate!

    def receive
      payload  = parse_payload
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
      Rails.logger.error("[IntegrationsController] #{e.class}: #{e.message}")
      render json: { success: false, error: "Internal error: Unexpected error" }, status: :internal_server_error
    end

    private

    def utils
      raise NotImplementedError, "utils must be implemented in subclass"
    end

    def parse_payload
      raise NotImplementedError, "payload parse must be implemented in subclass"
    end

    def validate!(payload)
      raise NotImplementedError, "payload validation must be implemented in subclass"
    end

    def processor
      raise NotImplementedError, "processor must be implemented in subclass"
    end
  end
end
