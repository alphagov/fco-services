require 'spec_helper'

describe EpdqTransactionsController do

  describe "start pages" do
    it "returns 404 status if slug is empty" do
      get :start, :slug => ""
      response.should be_not_found
    end

    context "given a valid transaction as the slug" do
      before do
        get :start, :slug => "pay-for-certificates-for-marriage"
      end

      it "is successful" do
        response.should be_success
      end

      it "renders the start template" do
        @controller.should render_template("start")
      end

      it "assigns the transaction details" do
        assigns(:transaction)[:title].should == "Pay for certificates for marriage"
        assigns(:transaction)[:slug].should == "pay-for-certificates-for-marriage"
        assigns(:transaction)[:document_cost].should == 65
        assigns(:transaction)[:registration].should be_false
      end
    end
  end

  describe "confirm pages" do
    it "returns 404 status if slug is empty" do
      post :confirm, :slug => ""
      response.should be_not_found
    end

    context "given valid values" do
      before do
        post :confirm, :slug => "pay-for-certificates-for-marriage", :transaction => {
          :document_count => "5",
          :postage => "yes"
        }
      end

      it "should calculate the correct total cost" do
        assigns(:calculation).total_cost.should == 335
        assigns(:calculation).item_list.should == "5 documents, plus postage,"
      end
    end
  end

end
