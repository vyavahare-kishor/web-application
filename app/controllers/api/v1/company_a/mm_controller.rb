module Api::V1::CompanyA
  class MmController < Api::V1::IntegrationsController
    private

    def utils
      CompanyA::Mm::Utils
    end

    def processor
      CompanyA::Mm::Processor.new
    end
  end
end
