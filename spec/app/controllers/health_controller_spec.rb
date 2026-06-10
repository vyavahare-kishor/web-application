require 'rails_helper'

describe HealthController, type: :controller do
  describe "GET #show" do
    subject(:show) { get :show }

    context 'any args' do
      it "returns ok status" do
        show
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ "status" => "ok" })
      end
    end
  end
end
