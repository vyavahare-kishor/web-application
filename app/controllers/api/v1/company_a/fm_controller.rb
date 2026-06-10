module Api::V1::CompanyA
  class FmController < Api::V1::IntegrationsController
    private

    def utils
      CompanyA::Fm::Utils
    end

    def processor
      CompanyA::Fm::Processor.new
    end
  end
end
