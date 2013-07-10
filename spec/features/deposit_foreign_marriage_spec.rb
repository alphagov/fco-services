# encoding: utf-8
require 'spec_helper'

describe "paying to deposit marriage and civil partnership documents" do
  it "renders the content and form" do
    visit "http://deposit-foreign-marriage.example.com/"

    within(:css, "header.page-header") do
      page.should have_content("Deposit foreign marriage or civil partnership certificates")
    end

    within(:css, "form") do
      page.should have_content("Deposit your marriage or civil partnership certificate at the General Register Office (GRO) for safe-keeping if you got married aboard and you’re resident in the UK.")

      page.should have_content("Each one costs £35.")
      page.should have_select("transaction_document_count", :options => ["1","2","3","4","5","6","7","8","9"])

      page.should have_content("Do you want to pay the £10 postage fee to have your documents returned?")
      page.should have_select("transaction_postage", :options => ["Yes", "No"])

      page.should have_button("Calculate total")
    end
  end

  context "given correct data" do
    before do
      visit "http://deposit-foreign-marriage.example.com/"

      within(:css, "form") do
        select "1", :from => "transaction_document_count"
        select "Yes", :from => "transaction_postage"
      end

      click_on "Calculate total"
    end

    it "calculates a total" do
      page.should have_content("The cost to deposit 1 certificate plus postage is £45")
    end

    it "generates an EPDQ form" do
      page.should have_selector("form[action^='https://mdepayments.epdq.co.uk'][method='post']")

      within(:css, "form.epdq-submit") do
        page.should have_selector("input[name='ORDERID']")
        page.should have_selector("input[name='PSPID']")
        page.should have_selector("input[name='SHASIGN']")

        page.should have_selector("input[name='AMOUNT'][value='4500']")
        page.should have_selector("input[name='CURRENCY'][value='GBP']")
        page.should have_selector("input[name='LANGUAGE'][value='en_GB']")
        page.should have_selector("input[name='ACCEPTURL'][value='http://deposit-foreign-marriage.example.com/done']")

        page.should have_button("Pay")
      end
    end
  end
end
