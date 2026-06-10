module Common::Concerns
  module AuthenticatedIntegration
    SESSION_TOKEN_HEADER = "authorization"

    def authenticate!
      utils.authenticate!(token:)
    end

    def utils
      raise NotImplementedError, "Utils method not implemented"
    end

    def token
      bearer = request.headers[SESSION_TOKEN_HEADER].to_s.presence
      unless bearer.present? && bearer.downcase.include?("bearer")
        raise Common::Errors::AuthenticationError, "Missing or invalid authentication token"
      end
      bearer.split.last
    end
  end
end
