require 'spec_helper'

describe Transaction do

  before do
    Transaction.file_path = Rails.root.join("spec/fixtures/transactions.yml")
    Transaction.transaction_list = nil
  end

  after do
    Transaction.file_path = nil
    Transaction.transaction_list = nil
  end

  describe "loads and memoizes the list of transactions" do
    it "loads the list of transactions" do
      Transaction.transaction_list.should == {
        "pay-for-gorilla-hire" => {
          "title" => "Pay for gorilla hire",
          "document_cost" => 120,
          "postage_cost" => 20,
          "document_types" => {
            "mountain_gorilla" => "Mountain gorilla rental agreement",
            "western_gorilla" => "Western gorilla rental agreement",
            "eastern_lowland_gorilla" => "Eastern lowland gorilla hire licence"
          },
          "registration" => true,
          "registration_cost" => 105,
          "registration_type" => "gorilla"
        }
      }
    end

    it "does not load the list of transactions more than once" do
      YAML.should_receive(:load).once.and_return( "list content" )

      Transaction.transaction_list.should == "list content"
      Transaction.transaction_list.should == "list content"
    end
  end

  describe "finding a transaction" do
    it "returns a transaction object for a valid slug" do
      transaction = Transaction.find("pay-for-gorilla-hire")

      transaction.should be_a(Transaction)
      transaction.slug.should == "pay-for-gorilla-hire"
      transaction.title.should == "Pay for gorilla hire"

      transaction.document_types.should == {
        "mountain_gorilla" => "Mountain gorilla rental agreement",
        "western_gorilla" => "Western gorilla rental agreement",
        "eastern_lowland_gorilla" => "Eastern lowland gorilla hire licence"
      }
      transaction.document_cost.should == 120
      transaction.postage_cost.should == 20

      transaction.registration.should be_true
      transaction.registration_cost.should == 105
      transaction.registration_type.should == "gorilla"
    end

    it "raises an exception if the transaction does not exist" do
      expect { Transaction.find("pay-for-a-free-exception") }.to raise_error(Transaction::TransactionNotFound)
    end
  end

  describe "matches? method for subdomain routing" do
    it "should return true if the request domain matches a transaction slug" do
      request = stub("Request", :subdomains => ['www', 'pay-for-gorilla-hire', 'service'])
      expect(Transaction.matches?(request)).to be_true
    end

    it "should support variable subdomain lengths" do
      request = stub("Request")
      request.stub(:subdomains).and_return(['www'])
      request.stub(:subdomains).with(0).and_return(['www', 'pay-for-gorilla-hire', 'service'])
      request.stub(:subdomains).with(1).and_return(['www', 'pay-for-gorilla-hire'])

      expect(Transaction.matches?(request)).to be_true
    end

    it "should return false with a subdomain that doesn't match" do
      request = stub("Request", :subdomains => ['www', 'pay-bear-tax', 'service'])
      expect(Transaction.matches?(request)).to be_false
    end

    it "should return false with no subdomain" do
      request = stub("Request", :subdomains => [])
      expect(Transaction.matches?(request)).to be_false
    end
  end
end
