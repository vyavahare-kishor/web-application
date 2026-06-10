require 'rails_helper'

RSpec.describe CompanyA::Fm::Processor, type: :model do
  describe '#process' do
    let(:payload) do
      {
        event_type: 'test_event',
        data: { key: 'value' }
      }
    end

    it 'logs the payload information' do
      expect(Rails.logger).to receive(:info).with("[CompanyA::FM] Processing payload: #{payload.inspect}")

      processor = described_class.new
      processor.process(payload)
    end
  end
end
