module Api::V1
  class IntegrationsController < ApplicationController
    include Common::Concerns::AuthenticatedIntegration

    before_action :authenticate!
  end
end
