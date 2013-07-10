require 'spec_helper'

feature "redirecting an invalid transaction" do
  it "should redirect / for an unknown slug to www.gov.uk" do
    get "http://pay-bear-tax.example.com/"
    expect(response).to redirect_to("https://www.gov.uk/")
    expect(response.status).to eq(302)
  end
end
