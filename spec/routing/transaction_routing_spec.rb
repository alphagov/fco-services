require 'spec_helper'

describe "Routing requests to transactions" do

  context "with a subdomain that matches a transaction" do
    let(:domain) { "www.deposit-foreign-marriage.example.com" }

    it "should route /start to the start action" do
      expect(:get => "http://#{domain}/start").to route_to(
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

    it "should route / to the root_redirect action" do
      expect(:get => "http://#{domain}/").to route_to(
        :controller => "epdq_transactions",
        :action => "root_redirect"
      )
    end

    it "should match with any length of domain" do
      prefix = "www.deposit-foreign-marriage"
      expect(:get => "http://#{prefix}.service.gov.uk/start").to route_to(:controller => "epdq_transactions", :action => "start")
      expect(:get => "http://#{prefix}.service.alphagov.co.uk/start").to route_to(:controller => "epdq_transactions", :action => "start")
      expect(:get => "http://#{prefix}.service.preview.alphagov.co.uk/start").to route_to(:controller => "epdq_transactions", :action => "start")
      expect(:get => "http://#{prefix}.service.really.long.domain.preview.alphagov.co.uk/start").to route_to(:controller => "epdq_transactions", :action => "start")
      expect(:get => "http://#{prefix}.dev/start").to route_to(:controller => "epdq_transactions", :action => "start")
    end

    it "should work with any prefix" do
      suffix = "deposit-foreign-marriage.service.gov.uk"
      expect(:get => "http://www.#{suffix}/start").to route_to(:controller => "epdq_transactions", :action => "start")
      expect(:get => "http://www-origin.#{suffix}/start").to route_to(:controller => "epdq_transactions", :action => "start")
      expect(:get => "http://www-preview.#{suffix}/start").to route_to(:controller => "epdq_transactions", :action => "start")
      expect(:get => "http://foo.#{suffix}/start").to route_to(:controller => "epdq_transactions", :action => "start")
    end
  end

  context "with a subdomain that doesn't match a transaction" do
    let(:domain) { "www.fooey.example.com" }

    it "should not route /start" do
      expect(:get => "http://#{domain}/start").not_to be_routable
    end

    it "should not route /confirm" do
      expect(:get => "http://#{domain}/confirm").not_to be_routable
      expect(:post => "http://#{domain}/confirm").not_to be_routable
    end

    it "should not route /done" do
      expect(:get => "http://#{domain}/done").not_to be_routable
    end
  end
end
