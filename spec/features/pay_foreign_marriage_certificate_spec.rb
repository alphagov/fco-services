# encoding: utf-8
require 'spec_helper'

describe "paying for a certificate for marriage" do
  it "renders the content and form" do
    visit "http://www.pay-foreign-marriage-certificates.example.com/start"

    within(:css, "header.page-header") do
      page.should have_content("Payment for certificates to get married abroad")
    end

    within(:css, "#content form") do
      page.should have_content("Pay for documents you need from the Foreign & Commonwealth Office (FCO) to prove you’re allowed to get married abroad.")
      page.should have_unchecked_field("Certificate of no impediment")
      page.should have_unchecked_field("Nulla Osta")
      page.should have_unchecked_field("Certificate of custom law")

      page.should have_content("Each certificate costs £65.")
      page.should have_select("transaction_document_count", :options => ["1","2","3","4","5","6","7","8","9"])

      page.should have_content("Do you want to pay the £10 postage fee to have your documents returned?")
      page.should have_select("transaction_postage", :options => ["Yes", "No"])

      page.should have_button("Calculate total")
    end

    find("#wrapper")["data-journey"].should == "pay-foreign-marriage-certificates:start"

  end

  it "should redirect a GET to /confirm back to the start" do
    visit "http://www.pay-foreign-marriage-certificates.example.com/confirm"

    i_should_be_on "/start"

    page.should have_content("How many do you need?")
  end

  context "given correct data" do
    before do
      visit "http://www.pay-foreign-marriage-certificates.example.com/start"

      within(:css, "#content form") do
        choose "Certificate of custom law"
        select "3", :from => "transaction_document_count"
        select "Yes", :from => "transaction_postage"
      end

      click_on "Calculate total"
    end

    it "calculates a total" do
      page.should have_content("The cost of 3 certificates of custom law plus postage is £205")
    end

    it "generates an EPDQ form" do
      page.should have_selector("form[action^='https://mdepayments.epdq.co.uk'][method='post']")

      within(:css, "form.epdq-submit") do
        page.should have_selector("input[name='ORDERID']")
        page.should have_selector("input[name='PSPID']")
        page.should have_selector("input[name='SHASIGN']")

        page.should have_selector("input[name='AMOUNT'][value='20500']")
        page.should have_selector("input[name='CURRENCY'][value='GBP']")
        page.should have_selector("input[name='LANGUAGE'][value='en_GB']")
        page.should have_selector("input[name='ACCEPTURL'][value='http://www.pay-foreign-marriage-certificates.example.com/done']")
        page.should have_selector("input[name='PARAMPLUS'][value='document_count=3&postage=yes']")
        page.should have_selector("input[name='TP'][value='http://www.pay-foreign-marriage-certificates.example.com/assets/barclays_epdq.html']")

        page.should have_button("Pay")
      end
    end
  end

  it "displays an error and renders the form given incorrect data" do
    visit "http://www.pay-foreign-marriage-certificates.example.com/start"

    within(:css, "#content form") do
      select "3", :from => "transaction_document_count"
      select "Yes", :from => "transaction_postage"
    end

    click_on "Calculate total"

    page.should have_selector("p.error-message", :text => "Please choose a document type")
    page.should have_content("Which type of certificate do you need?")
  end

  describe "visiting the done page" do
    context "given valid payment details" do
      before do
        visit "http://www.pay-foreign-marriage-certificates.example.com/done?orderID=test&currency=GBP&amount=45&PM=CreditCard&ACCEPTANCE=test123&STATUS=5&CARDNO=XXXXXXXXXXXX1111&CN=MR+MICKEY+MOUSE&TRXDATE=03%2F11%2F13&PAYID=12345678&NCERROR=0&BRAND=VISA&SHASIGN=6ACE8B0C8E0B427137F6D7FF86272AA570255003&document_count=5&postage=yes"
      end

      it "should display the done page content" do
        within(:css, "header.page-header") do
          page.should have_content("Payment for certificates to get married abroad")
        end

        page.should have_content("Your payment reference is")
      end

      it "should display the order number" do
        page.should have_content("12345678")
      end

      it "should display the number of documents ordered" do
        page.should have_content("You have paid for 5 certificates plus postage.")
      end
    end

    context "given valid payment details and additional parameters" do
      before do
        visit "http://www.pay-foreign-marriage-certificates.example.com/done?orderID=test&currency=GBP&amount=45&PM=CreditCard&ACCEPTANCE=test123&STATUS=5&CARDNO=XXXXXXXXXXXX1111&CN=MR+MICKEY+MOUSE&TRXDATE=03%2F11%2F13&PAYID=12345678&NCERROR=0&BRAND=VISA&SHASIGN=6ACE8B0C8E0B427137F6D7FF86272AA570255003&registration_count=1&document_count=4"
      end

      it "should display the number of documents ordered" do
        page.should have_content("You have paid for 1 registration and 4 certificates.")
      end
    end

    context "invalid payment details" do
      it "should display the error page content" do
        visit "http://www.pay-foreign-marriage-certificates.example.com/done?orderID=test&currency=GBP&amount=45&PM=CreditCard&ACCEPTANCE=test123&STATUS=5&CARDNO=XXXXXXXXXXXX1111&CN=MISS+MINNIE+MOUSE&SHASIGN=yarrrrr"
        within(:css, "header.page-header") do
          page.should have_content("Payment for certificates to get married abroad")
        end

        page.should have_content("There was a problem making your payment to the Foreign & Commonwealth Office.")
      end

      it "should display the error page with a missing SHASIGN" do
        visit "http://www.pay-foreign-marriage-certificates.example.com/done?orderID=test&currency=GBP&amount=45&PM=CreditCard&ACCEPTANCE=test123&STATUS=5&CARDNO=XXXXXXXXXXXX1111&CN=MISS+MINNIE+MOUSE"

        within(:css, "header.page-header") do
          page.should have_content("Payment for certificates to get married abroad")
        end

        page.should have_content("There was a problem making your payment to the Foreign & Commonwealth Office.")
      end
    end
  end
end
