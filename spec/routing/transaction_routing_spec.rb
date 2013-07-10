require 'spec_helper'

describe "Routing requests to transactions" do

  context "with a subdomain that matches a transaction" do
    let(:domain) { "deposit-foreign-marriage.example.com" }

    it "should route / to the start action" do
      expect(:get => "http://#{domain}/").to route_to(
        :controller => "epdq_transactions",
        :action => "start"
      )
    end

    it "should route a POST to /confirm to the confirm action" do
      expect(:post => "http://#{domain}/confirm").to route_to(
        :controller => "epdq_transactions",
        :action => "confirm"
      )
    end

    it "should route /done to the done action" do
      expect(:get => "http://#{domain}/done").to route_to(
        :controller => "epdq_transactions",
        :action => "done"
      )
    end

    it "should match with any length of domain" do
      slug = "deposit-foreign-marriage"
      expect(:get => "http://#{slug}.service.gov.uk/").to route_to(:controller => "epdq_transactions", :action => "start")
      expect(:get => "http://#{slug}.service.alphagov.co.uk/").to route_to(:controller => "epdq_transactions", :action => "start")
      expect(:get => "http://#{slug}.service.preview.alphagov.co.uk/").to route_to(:controller => "epdq_transactions", :action => "start")
      expect(:get => "http://#{slug}.service.really.long.domain.preview.alphagov.co.uk/").to route_to(:controller => "epdq_transactions", :action => "start")
      expect(:get => "http://#{slug}.dev/").to route_to(:controller => "epdq_transactions", :action => "start")
    end
  end

  context "with a subdomain that doesn't match a transaction" do
    let(:domain) { "fooey.example.com" }

    it "should not route /confirm" do
      expect(:get => "http://#{domain}/confirm").not_to be_routable
      expect(:post => "http://#{domain}/confirm").not_to be_routable
    end

    it "should not route /done" do
      expect(:get => "http://#{domain}/done").not_to be_routable
    end
  end
end
