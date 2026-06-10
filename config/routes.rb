Rails.application.routes.draw do
  get "/health", to: "health#show"

  namespace :api do
    namespace :v1 do
      post "company_a/fm/receive", to: "company_a/fm#receive"
      post "company_a/mm/receive", to: "company_a/mm#receive"
    end
  end
end
