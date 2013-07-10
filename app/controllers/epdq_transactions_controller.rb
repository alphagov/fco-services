class EpdqTransactionsController < ApplicationController

  before_filter :find_transaction, :except => :index
  before_filter :set_expiry, :only => :start

  rescue_from Transaction::TransactionNotFound, :with => :error_404

  def index
  end

  def show
    redirect_to transaction_path(@transaction.slug)
  end

  def start
    @journey_description = journey_description(:start)
  end

  def confirm
    @calculation = @transaction.calculate_total(params[:transaction])
    @epdq_request = build_epdq_request(@transaction, @calculation.total_cost)
    @journey_description = journey_description(:confirm)
  rescue Transaction::InvalidDocumentType
    @journey_description = journey_description(:invalid_form)
    @errors = [:document_type]
    render :action => "start"
  rescue Transaction::InvalidPostageOption
    @journey_description = journey_description(:invalid_form)
    @errors = [:postage_option]
    render :action => "start"
  rescue Transaction::InvalidDocumentCount
    @journey_description = journey_description(:invalid_form)
    @errors = [:document_count]
    render :action => "start"
  end

  def done
    @epdq_response = EPDQ::Response.new(request.query_string, @transaction.account, Transaction::PARAMPLUS_KEYS)

    if @epdq_response.valid_shasign?
      @journey_description = journey_description(:done)
      render "done"
    else
      @journey_description = journey_description(:payment_error)
      render "payment_error"
    end
  end

private
  def find_transaction
    @transaction = Transaction.find(request.subdomains(0).first)
  end

  def build_epdq_request(transaction, total_cost_in_gbp)
    @epdq_request = EPDQ::Request.new(
      :account => transaction.account,
      :orderid => SecureRandom.hex(15),
      :amount => (total_cost_in_gbp * 100).round,
      :currency => "GBP",
      :language => "en_GB",
      :accepturl => transaction_done_url,
      :paramplus => paramplus_value,
      :tp => "#{Plek.current.asset_root}/templates/barclays_epdq.html"
    )
  end

  def paramplus_value
    [].tap do |ary|
      Transaction::PARAMPLUS_KEYS.each do |key|
        if params[:transaction].has_key?(key)
          ary << "#{key}=#{params[:transaction][key]}"
        end
      end
    end.join('&')
  end

  def journey_description(step)
    "#{@transaction.slug}:#{step}"
  end

end
