require 'rails_helper'
require 'ostruct'

describe Common::Concerns::AuthenticatedIntegration do
  let(:test_class) do
    Class.new do
      include Common::Concerns::AuthenticatedIntegration

      attr_reader :request

      def initialize(headers = {})
        @request = OpenStruct.new(headers: headers)
      end
    end
  end

  let(:headers) { {} }
  let!(:instance) { test_class.new(headers) }

  describe '#utils' do
    subject(:utils) { instance.utils }

    it 'raises NotImplementedError' do
      expect { utils }.to raise_error(NotImplementedError, "Utils method not implemented")
    end
  end

  describe '#token' do
    subject(:token) { instance.token }

    context 'when the authorization header is missing' do
      let(:headers) { {} }

      it 'raises Common::Errors::AuthenticationError' do
        expect { token }.to raise_error(Common::Errors::AuthenticationError, "Missing or invalid authentication token")
      end
    end

    context 'when the authorization header does not include "bearer"' do
      let(:headers) { { 'authorization' => 'Basic abc123' } }

      it 'raises Common::Errors::AuthenticationError' do
        expect { token }.to raise_error(Common::Errors::AuthenticationError, "Missing or invalid authentication token")
      end
    end

    context 'when a valid bearer token is present' do
      let(:headers) { { 'authorization' => 'Bearer my-secret-token' } }

      it 'returns the token value' do
        expect(token).to eq('my-secret-token')
      end
    end

    context 'when bearer casing is mixed' do
      let(:headers) { { 'authorization' => 'BEARER my-secret-token' } }

      it 'returns the token value' do
        expect(instance.token).to eq('my-secret-token')
      end
    end
  end

  describe '#authenticate!' do
    before do
      expect(instance).to receive(:utils).and_return(Common::Utils)
      expect(instance).to receive(:token).and_return('my-secret-token')
    end

    it 'delegates to utils.authenticate! with the token' do
      expect(Common::Utils).to receive(:authenticate!).with(token: 'my-secret-token')
      instance.authenticate!
    end
  end
end
