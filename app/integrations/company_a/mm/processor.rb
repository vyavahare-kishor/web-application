module CompanyA::Mm
  class Processor

    def process(payload)
      Rails.logger.info("[CompanyA::MM] Processing payload: #{payload.inspect}")
    end
  end
end
