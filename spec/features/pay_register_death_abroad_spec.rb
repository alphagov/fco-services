# encoding: utf-8
require 'spec_helper'

describe "paying to register a death abroad" do
  it "renders the content and form" do
    visit "http://www.pay-register-death-abroad.example.com/start"

    within(:css, "header.page-header") do
      page.should have_content("Payment to register a death abroad")
    end

    within(:css, "#content form") do
      page.should have_content("Pay the Foreign & Commonwealth Office (FCO) to register the death of a British national abroad. You must be back in the UK to use this service.")
      page.should have_content("Each one costs £105.")
      page.should have_select("transaction_registration_count", :options => ["1","2","3","4","5","6","7","8","9"])

      page.should have_content("How many death certificates do you need?")
      page.should have_content("Each one costs £65.")
      page.should have_select("transaction_document_count", :options => ["1","2","3","4","5","6","7","8","9"])

      page.should have_content("Do you want to pay the £10 postage fee to have your documents returned?")
      page.should have_select("transaction_postage", :options => ["Yes", "No"])

      page.should have_content("You must be back in the UK to use this service.")

      page.should have_button("Calculate total")
    end
  end

  context "given correct data" do
    before do
      visit "http://www.pay-register-death-abroad.example.com/start"

      within(:css, "#content form") do
        select "5", :from => "transaction_registration_count"
        select "1", :from => "transaction_document_count"
        select "Yes", :from => "transaction_postage"
      end

      click_on "Calculate total"
    end

    it "calculates a total" do
      page.should have_content("The cost for 5 registrations and 1 certificate plus postage is £600")
    end

    it "generates an EPDQ form" do
      page.should have_selector("form[action^='https://mdepayments.epdq.co.uk'][method='post']")

      within(:css, "form.epdq-submit") do
        page.should have_selector("input[name='ORDERID']")
        page.should have_selector("input[name='PSPID']")
        page.should have_selector("input[name='SHASIGN']")

        page.should have_selector("input[name='AMOUNT'][value='60000']")
        page.should have_selector("input[name='CURRENCY'][value='GBP']")
        page.should have_selector("input[name='LANGUAGE'][value='en_GB']")
        page.should have_selector("input[name='ACCEPTURL'][value='http://www.pay-register-death-abroad.example.com/done']")

        page.should have_button("Pay")
      end
    end
  end
end
