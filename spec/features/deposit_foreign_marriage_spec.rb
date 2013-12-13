# encoding: utf-8
require 'spec_helper'

describe "paying to deposit marriage and civil partnership documents" do
  it "renders the content and form" do
    visit "http://www.deposit-foreign-marriage.example.com/start"

    within(:css, "header.page-header") do
      page.should have_content("Deposit foreign marriage or civil partnership certificates")
    end

    within(:css, "#content form") do
      page.should have_content("Deposit your marriage or civil partnership certificate at the General Register Office (GRO) for safe-keeping if you got married abroad and you’re resident in the UK.")

      page.should have_content("From 1 January 2014 this service is no longer available. Any applications submitted after this date will be cancelled and any payment refunded.")

      page.should have_content("Each one costs £35.")
      page.should have_select("transaction_document_count", :options => ["1","2","3","4","5","6","7","8","9"])

      page.should have_content("Do you want to pay the £5 postage fee to have your documents returned?")
      page.should have_select("transaction_postage", :options => ["Yes", "No"])

      page.should have_button("Calculate total")
    end
  end

  context "given correct data" do
    before do
      visit "http://www.deposit-foreign-marriage.example.com/start"

      within(:css, "#content form") do
        select "1", :from => "transaction_document_count"
        select "Yes", :from => "transaction_postage"
      end

      click_on "Calculate total"
    end

    it "calculates a total" do
      page.should have_content("The cost to deposit 1 certificate plus postage is £40")
      page.should have_content("From 1 January 2014 this service is no longer available. Any applications submitted after this date will be cancelled and any payment refunded.")
    end

    it "generates an EPDQ form" do
      page.should have_selector("form[action^='https://mdepayments.epdq.co.uk'][method='post']")

      within(:css, "form.epdq-submit") do
        page.should have_selector("input[name='ORDERID']")
        page.should have_selector("input[name='PSPID']")
        page.should have_selector("input[name='SHASIGN']")

        page.should have_selector("input[name='AMOUNT'][value='4000']")
        page.should have_selector("input[name='CURRENCY'][value='GBP']")
        page.should have_selector("input[name='LANGUAGE'][value='en_GB']")
        page.should have_selector("input[name='ACCEPTURL'][value='http://www.deposit-foreign-marriage.example.com/done']")

        page.should have_button("Pay")
      end
    end
  end
end
