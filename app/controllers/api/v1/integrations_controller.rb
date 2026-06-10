module Api::V1
  class IntegrationsController < ApplicationController
    include AuthenticatedIntegration

    before_action :authenticate_integration!
  end
end
