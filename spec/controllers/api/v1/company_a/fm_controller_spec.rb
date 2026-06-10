require "rails_helper"

RSpec.describe "Api::V1::CompanyA::FmController", type: :request do
  let(:processor) { instance_double(CompanyA::Fm::Processor) }

  before do
    allow(CompanyA::Fm::Processor)
      .to receive(:new)
      .and_return(processor)

    allow(processor).to receive(:process)
  end

  let(:valid_payload) do
    {
      event_type: "order_created",
      data: {
        id: "123"
      }
    }
  end

  let(:headers) do
    {
      "authorization" => "Bearer test-token",
      "CONTENT_TYPE" => "application/json"
    }
  end

  before do
    allow(CompanyA::Fm::Utils)
      .to receive(:authenticate!)
      .with(token: "test-token")
      .and_return(true)
  end

  describe "POST /api/v1/company_a/fm/receive" do
    subject(:make_request) do
      post "/api/v1/company_a/fm/receive",
           params: payload.to_json,
           headers: headers
    end

    let(:payload) { valid_payload }

    context "when payload is valid" do
      it "processes the webhook successfully" do
        make_request

        expect(response).to have_http_status(:ok)

        expect(JSON.parse(response.body)).to eq(
          "success" => true,
          "message" => "Webhook received"
        )

        expect(processor).to have_received(:process).once
      end
    end

    context "when authentication fails" do
      before do
        allow(processor)
          .to receive(:process)
          .and_raise(
            Common::Errors::AuthenticationError,
            "Invalid token"
          )
      end

      it "returns unauthorized" do
        make_request

        expect(response).to have_http_status(:unauthorized)

        expect(JSON.parse(response.body)).to eq(
          "success" => false,
          "error" => "Invalid token"
        )
      end
    end

    context "when processor raises validation error" do
      before do
        allow(processor)
          .to receive(:process)
          .and_raise(
            Common::Errors::ValidationError,
            "Invalid data"
          )
      end

      it "returns unprocessable entity" do
        make_request

        expect(response).to have_http_status(:unprocessable_entity)

        expect(JSON.parse(response.body)).to eq(
          "success" => false,
          "error" => "Invalid data"
        )
      end
    end

    context "when processor raises server error" do
      before do
        allow(processor)
          .to receive(:process)
          .and_raise(
            Common::Errors::ServerError,
            "Service unavailable"
          )
      end

      it "returns service unavailable" do
        make_request

        expect(response).to have_http_status(:service_unavailable)

        expect(JSON.parse(response.body)).to eq(
          "success" => false,
          "error" => "Service unavailable"
        )
      end
    end

    context "when unexpected error occurs" do
      before do
        allow(processor)
          .to receive(:process)
          .and_raise(StandardError, "Unexpected error")
      end

      it "returns internal server error" do
        make_request

        expect(response).to have_http_status(:internal_server_error)

        expect(JSON.parse(response.body)).to eq(
          "success" => false,
          "error" => "Internal error: Unexpected error"
        )
      end
    end

    context "when event_type is missing" do
      let(:payload) do
        {
          data: {
            id: "123"
          }
        }
      end

      it "returns validation error" do
        make_request

        expect(response).to have_http_status(:unprocessable_entity)

        expect(JSON.parse(response.body)).to eq(
          "success" => false,
          "error" => "Missing fields: event_type"
        )
      end
    end

    context "when data is missing" do
      let(:payload) do
        {
          event_type: "order_created"
        }
      end

      it "returns validation error" do
        make_request

        expect(response).to have_http_status(:unprocessable_entity)

        expect(JSON.parse(response.body)).to eq(
          "success" => false,
          "error" => "Missing fields: data"
        )
      end
    end

    context "when both fields are missing" do
      let(:payload) { {} }

      it "returns validation error" do
        make_request

        expect(response).to have_http_status(:unprocessable_entity)

        expect(JSON.parse(response.body)).to eq(
          "success" => false,
          "error" => "Missing fields: event_type, data"
        )
      end
    end

    context "when json is malformed" do
      it "returns validation error" do
        post "/api/v1/company_a/fm/receive",
             params: "{invalid_json",
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)

        expect(JSON.parse(response.body)).to eq(
          "success" => false,
          "error" => "Invalid JSON payload"
        )
      end
    end
  end
end
