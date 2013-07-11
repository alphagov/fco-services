require 'spec_helper'

describe EpdqTransactionsController do

  describe "start pages" do
    it "returns 404 status if slug doesn't match a transaction" do
      request.host = "www.pay-bear-tax.example.com"
      get :start
      response.should be_not_found
    end

    context "given a valid transaction in the hostname" do
      before do
        request.host = "www.pay-foreign-marriage-certificates.example.com"
        get :start
      end

      it "sets the correct expiry headers" do
        response.headers["Cache-Control"].should == "max-age=1800, public"
      end

      it "is successful" do
        response.should be_success
      end

      it "renders the start template" do
        @controller.should render_template("start")
      end

      it "assigns the transaction details" do
        assigns(:transaction).title.should == "Payment for certificates to get married abroad"
        assigns(:transaction).slug.should == "pay-foreign-marriage-certificates"
        assigns(:transaction).document_cost.should == 65
        assigns(:transaction).registration.should be_false
      end

      it "assigns the journey description" do
        assigns(:journey_description).should == "pay-foreign-marriage-certificates:start"
      end
    end

    it "works with short domains" do
      request.host = "www.pay-foreign-marriage-certificates.dev"
      get :start
      response.should be_success
    end
  end

  describe "root redirects" do
    it "should redirect a known slug to the www.gov.uk start page" do
      request.host = "www.pay-legalisation-drop-off.example.com"
      get :root_redirect
      response.should redirect_to("https://www.gov.uk/pay-legalisation-drop-off")
      response.status.should == 301
    end

    it "should set cache-control headers for the redirect" do
      request.host = "www.pay-legalisation-drop-off.example.com"
      get :root_redirect

      response.headers['Cache-Control'].should == "max-age=1800, public"
    end

    it "should 404 for an unknown slug" do
      request.host = "www.pay-bear-tax.example.com"
      get :root_redirect
      response.should be_not_found
    end
  end

  describe "confirm pages" do
    it "returns 404 status if slug doesn't match a transaction" do
      request.host = "www.pay-bear-tax.example.com"
      post :confirm
      response.should be_not_found
    end

    it "builds an epdq request with the correct account" do
      request.host = "www.pay-legalisation-drop-off.example.com"
      EPDQ::Request.should_receive(:new).with(hash_including(:account => "legalisation-drop-off"))

      post :confirm, :transaction => { :document_count => "5" }
    end

    context "given an invalid document count" do
      before do
        request.host = "www.pay-legalisation-drop-off.example.com"
        post :confirm, :transaction => {
          :document_count => "test",
          :postage => "yes",
        }
      end

      it "renders the start template" do
        @controller.should render_template("start")
        response.should be_success
      end

      it "assigns an error message" do
        assigns(:errors).should =~ [:document_count]
      end
    end

    context "given a zero document count" do
      before do
        request.host = "www.pay-legalisation-drop-off.example.com"
        post :confirm, :transaction => {
          :document_count => "0",
          :postage => "yes",
        }
      end

      it "renders the start template" do
        @controller.should render_template("start")
        response.should be_success
      end

      it "assigns an error message" do
        assigns(:errors).should =~ [:document_count]
      end
    end
    
    describe "with multiple document types" do
      context "given valid values" do
        before do
          request.host = "www.pay-foreign-marriage-certificates.example.com"
          post :confirm, :transaction => {
            :document_count => "5",
            :postage => "yes",
            :document_type => "nulla-osta"
          }
        end

        it "should calculate the correct total cost" do
          assigns(:calculation).total_cost.should == 335
          assigns(:calculation).item_list.should == "5 Nulla Ostas plus postage"
        end

        it "is successful" do
          response.should be_success
        end

        it "renders the confirm template" do
          @controller.should render_template("confirm")
        end

        it "assigns the transaction details" do
          assigns(:transaction).title.should == "Payment for certificates to get married abroad"
          assigns(:transaction).slug.should == "pay-foreign-marriage-certificates"
        end

        it "assigns an EPDQ request with the correct amount" do
          assigns(:epdq_request).parameters[:orderid].should_not be_blank
          assigns(:epdq_request).parameters[:amount].should == 33500
          assigns(:epdq_request).parameters[:accepturl].should == "http://www.pay-foreign-marriage-certificates.example.com/done"
        end

        it "assigns the journey description" do
          assigns(:journey_description).should == "pay-foreign-marriage-certificates:confirm"
        end
      end

      context "given no document type" do
        before do
          request.host = "www.pay-foreign-marriage-certificates.example.com"
          post :confirm, :transaction => {
            :document_count => "5",
            :postage => "yes",
          }
        end

        it "renders the start template" do
          @controller.should render_template("start")
        end

        it "assigns an error message" do
          assigns(:errors).should =~ [:document_type]
        end

        it "assigns the journey description" do
          assigns(:journey_description).should == "pay-foreign-marriage-certificates:invalid_form"
        end
      end

      context "given an invalid document type" do
        before do
          request.host = "www.pay-foreign-marriage-certificates.example.com"
          post :confirm, :transaction => {
            :document_count => "5",
            :postage => "yes",
            :document_type => "nyan"
          }
        end

        it "renders the start template" do
          @controller.should render_template("start")
        end

        it "assigns an error message" do
          assigns(:errors).should =~ [:document_type]
        end

        it "assigns the journey description" do
          assigns(:journey_description).should == "pay-foreign-marriage-certificates:invalid_form"
        end
      end
    end

    describe "with registration count" do
      context "given valid values" do
        before do
          request.host = "www.pay-register-birth-abroad.example.com"
          post :confirm, :transaction => {
            :registration_count => "5",
            :document_count => "5",
            :postage => "yes"
          }
        end

        it "should calculate the correct total cost" do
          assigns(:calculation).total_cost.should == 860
          assigns(:calculation).item_list.should == "5 birth registrations and 5 birth certificates plus postage"
        end

        it "is successful" do
          response.should be_success
        end

        it "renders the confirm template" do
          @controller.should render_template("confirm")
        end

        it "assigns the transaction details" do
          assigns(:transaction).title.should == "Payment to register a birth abroad"
          assigns(:transaction).slug.should == "pay-register-birth-abroad"
        end

        it "assigns an EPDQ request with the correct amount" do
          assigns(:epdq_request).parameters[:orderid].should_not be_blank
          assigns(:epdq_request).parameters[:amount].should == 86000
          assigns(:epdq_request).parameters[:accepturl].should == "http://www.pay-register-birth-abroad.example.com/done"
        end

        it "assigns the journey description" do
          assigns(:journey_description).should == "pay-register-birth-abroad:confirm"
        end
      end
    end

    describe "without multiple document types" do
      context "given valid values" do
        before do
          request.host = "www.deposit-foreign-marriage.example.com"
          post :confirm, :transaction => {
            :document_count => "3",
            :postage => "no"
          }
        end

        it "should calculate the correct total cost" do
          assigns(:calculation).total_cost.should == 105
          assigns(:calculation).item_list.should == "3 certificates"
        end

        it "is successful" do
          response.should be_success
        end

        it "renders the confirm template" do
          @controller.should render_template("confirm")
        end

        it "assigns the journey description" do
          assigns(:journey_description).should == "deposit-foreign-marriage:confirm"
        end
      end
    end
  end

  describe "done pages" do
    it "returns 404 status if slug doesn't match a transaction" do
      request.host = "www.pay-bear-tax.example.com"
      post :confirm
      response.should be_not_found
    end

    it "should build an EPDQ response for the correct account" do
      response_stub = stub(:valid_shasign? => true)
      EPDQ::Response.should_receive(:new).with(anything(), "birth-death-marriage", Transaction::PARAMPLUS_KEYS)
        .and_return(response_stub)

      request.host = "www.deposit-foreign-marriage.example.com"
      get :done
    end

    describe "for a standard transaction" do
      context "given valid parameters" do
        before do
          request.host = "www.deposit-foreign-marriage.example.com"
          get :done,
            "orderID" => "test",
            "currency" => "GBP",
            "amount" => 45,
            "PM" => "CreditCard",
            "ACCEPTANCE" => "test123",
            "STATUS" => 5,
            "CARDNO" => "XXXXXXXXXXXX1111",
            "CN" => "MR MICKEY MOUSE",
            "TRXDATE" => "03/11/13",
            "PAYID" => 12345678,
            "NCERROR" => 0,
            "BRAND" => "VISA",
            "SHASIGN" => "6ACE8B0C8E0B427137F6D7FF86272AA570255003",
            "document_count" => "3",
            "postage" => "yes"
        end

        it "is successful" do
          response.should be_success
        end

        it "renders the done template" do
          @controller.should render_template("done")
        end

        it "assigns the transaction details" do
          assigns(:transaction).title.should == "Deposit foreign marriage or civil partnership certificates"
          assigns(:transaction).slug.should == "deposit-foreign-marriage"
        end

        it "assigns the epdq response" do
          assigns(:epdq_response).parameters[:payid].should == "12345678"
          assigns(:epdq_response).parameters[:orderid].should == "test"

          assigns(:epdq_response).parameters[:document_count].should == "3"
          assigns(:epdq_response).parameters[:postage].should == "yes"
        end

        it "assigns the journey description" do
          assigns(:journey_description).should == "deposit-foreign-marriage:done"
        end
      end

      context "given invalid parameters" do
        before do
          request.host = "www.deposit-foreign-marriage.example.com"
          get :done,
            "orderID" => "test",
            "currency" => "GBP",
            "amount" => 45,
            "PM" => "CreditCard",
            "ACCEPTANCE" => "test123",
            "STATUS" => 5,
            "CARDNO" => "XXXXXXXXXXXX1111",
            "CN" => "MR MICKEY MOUSE",
            "TRXDATE" => "03/11/13",
            "PAYID" => 12345678,
            "NCERROR" => 0,
            "BRAND" => "VISA",
            "SHASIGN" => "something which is not correct"
        end

        it "should be successful" do
          response.should be_success
        end

        it "should render the error template" do
          @controller.should render_template("error")
        end

        it "assigns the journey description" do
          assigns(:journey_description).should == "deposit-foreign-marriage:payment_error"
        end
      end

    end
  end
end
