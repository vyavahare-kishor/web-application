module Common
  module Errors
    class NotImplementedError < StandardError; end
    class IntegrationError < StandardError; end
    class AuthenticationError < IntegrationError; end
    class NotFoundError < IntegrationError; end
    class ValidationError < IntegrationError; end
    class ServerError < IntegrationError; end
  end
end
