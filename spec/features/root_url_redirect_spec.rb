require 'spec_helper'

feature "redirecting the root url" do

  it "should redirect a known slug to the www.gov.uk start page" do
    get "http://www.pay-legalisation-post.example.com/"
    expect(response).to redirect_to("https://www.gov.uk/pay-legalisation-post")
    expect(response.status).to eq(301)
  end

  it "should redirect an unknown slug to www.gov.uk" do
    get "http://www.pay-bear-tax.example.com/"
    expect(response).to redirect_to("https://www.gov.uk/")
    expect(response.status).to eq(302)
  end
end
