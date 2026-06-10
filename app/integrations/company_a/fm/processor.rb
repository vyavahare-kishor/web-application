module CompanyA::Fm
  class Processor

    def process(payload)
      Rails.logger.info("[CompanyA::FM] Processing payload: #{payload.inspect}")
    end
  end
end
