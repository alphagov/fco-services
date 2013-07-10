#coding: utf-8
require "spec_helper"

feature "epdq transactions" do
  it "renders a 404 error on for an invalid transaction slug" do
    visit "http://pay-for-bunting.example.com/"

    page.status_code.should == 404
  end
end
