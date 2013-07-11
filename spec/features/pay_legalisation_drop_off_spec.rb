# encoding: utf-8
require 'spec_helper'

describe "paying to get a document legalised using the drop-off service" do
  it "renders the content and form" do
    visit "http://www.pay-legalisation-drop-off.example.com/start"

    within(:css, "header.page-header") do
      page.should have_content("Pay to legalise documents using the drop-off service")
    end

    within(:css, "form") do
      page.should have_content("How many documents do you want legalised?")

      page.should have_content("Each document costs £75.")
      page.should have_field("transaction_document_count")

      page.should have_no_content("Which postage method do you require?")
      page.should have_no_content("Do you require postage?")
      page.should have_no_select("transaction_postage")

      page.should have_button("Calculate total")
    end
  end

  context "given correct data" do
    before do
      visit "http://www.pay-legalisation-drop-off.example.com/start"

      within(:css, "form") do
        fill_in "transaction_document_count", :with => "5"
      end

      click_on "Calculate total"
    end

    it "calculates a total" do
      page.should have_content("It costs £375 for 5 documents")
    end

    it "generates an EPDQ form" do
      page.should have_selector("form[action^='https://mdepayments.epdq.co.uk'][method='post']")

      within(:css, "form.epdq-submit") do
        page.should have_selector("input[name='ORDERID']")
        page.should have_selector("input[name='PSPID']")
        page.should have_selector("input[name='SHASIGN']")

        page.should have_selector("input[name='AMOUNT'][value='37500']")
        page.should have_selector("input[name='CURRENCY'][value='GBP']")
        page.should have_selector("input[name='LANGUAGE'][value='en_GB']")
        page.should have_selector("input[name='ACCEPTURL'][value='http://www.pay-legalisation-drop-off.example.com/done']")

        page.should have_button("Pay")
      end
    end
  end

  it "returns an error if document count is not an integer" do
    visit "http://www.pay-legalisation-drop-off.example.com/start"

    fill_in "transaction_document_count", :with => "definitely not a number"
    click_on "Calculate total"

    page.should have_selector("p.error-message", :text => "Document count must be a number")
    page.should_not have_button "Pay"
  end
end
