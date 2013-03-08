class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper

  def error_404; error 404; end

  private

  def error(status_code)
    render status: status_code, text: "#{status_code} error"
  end
end
