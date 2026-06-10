require "rails_helper"

RSpec.describe "Api::V1::CompanyA::MmController", type: :request do
  let(:processor) { instance_double(CompanyA::Mm::Processor) }

  before do
    allow(CompanyA::Mm::Processor)
      .to receive(:new)
      .and_return(processor)

    allow(processor).to receive(:process)
  end

  let(:valid_xml) do
    <<~XML
      <root>
        <event_type>order_created</event_type>
        <data>
          <id>123</id>
        </data>
      </root>
    XML
  end

  let(:headers) do
    {
      "authorization" => "Bearer test-token",
      "CONTENT_TYPE" => "application/xml"
    }
  end

  before do
    allow(CompanyA::Mm::Utils)
      .to receive(:authenticate!)
      .with(token: "test-token")
      .and_return(true)
  end

  describe "POST /api/v1/company_a/mm/receive" do
    subject(:make_request) do
      post "/api/v1/company_a/mm/receive",
          params: valid_xml,
          headers: headers
    end

    context "with valid payload" do
      it "processes webhook and returns success" do
        make_request

        expect(response).to have_http_status(:ok)

        expect(JSON.parse(response.body)).to eq(
          "success" => true,
          "message" => "Webhook received"
        )

        expect(processor).to have_received(:process)
      end
    end

    context "when authentication error occurs" do
      before do
        allow(processor)
          .to receive(:process)
          .and_raise(Common::Errors::AuthenticationError, "Invalid token")
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

    context "when validation error occurs during processing" do
      before do
        allow(processor)
          .to receive(:process)
          .and_raise(Common::Errors::ValidationError, "Invalid payload")
      end

      it "returns unprocessable entity" do
        make_request

        expect(response).to have_http_status(:unprocessable_entity)

        expect(JSON.parse(response.body)).to eq(
          "success" => false,
          "error" => "Invalid payload"
        )
      end
    end

    context "when server error occurs" do
      before do
        allow(processor)
          .to receive(:process)
          .and_raise(Common::Errors::ServerError, "External service unavailable")
      end

      it "returns service unavailable" do
        make_request

        expect(response).to have_http_status(:service_unavailable)

        expect(JSON.parse(response.body)).to eq(
          "success" => false,
          "error" => "External service unavailable"
        )
      end
    end

    context "when unexpected error occurs" do
      before do
        allow(processor)
          .to receive(:process)
          .and_raise(StandardError, "Something went wrong")
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

    context "when required fields are missing" do
      let(:invalid_xml) do
        <<~XML
          <root>
            <event_type>order_created</event_type>
          </root>
        XML
      end

      it "returns validation error" do
        post "/api/v1/company_a/mm/receive",
             params: invalid_xml,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)

        expect(JSON.parse(response.body)).to eq(
          "success" => false,
          "error" => "Missing fields: data"
        )
      end
    end

    context "when xml is malformed" do
      let(:malformed_xml) do
        "<root><event_type>abc</root>"
      end

      it "returns validation error" do
        post "/api/v1/company_a/mm/receive",
             params: malformed_xml,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)

        expect(JSON.parse(response.body)["success"]).to eq(false)
      end
    end
  end
end
