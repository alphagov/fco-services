class EpdqTransactionsController < ApplicationController

  before_filter :find_transaction

  class InvalidDocumentType < Exception; end

  def start

  end

  def confirm
    @calculation = calculate_total(@transaction, params[:transaction])
  rescue InvalidDocumentType
    @errors = [:document_type]
    render :action => "start"
  end

  private
    def find_transaction
      @transaction_list ||= YAML.load( File.open( Rails.root.join("lib", "epdq_transactions.yml") ) )
      @transaction = @transaction_list[params[:slug]]

      unless @transaction.present?
        error_404
        return
      end

      @transaction.symbolize_keys!
      @transaction[:slug] = params[:slug]
    end

    def calculate_total(transaction, values)
      document_count = values[:document_count].to_i
      postage = values[:postage] == "yes"
      document_type = values[:document_type]

      document_total = @transaction[:document_cost] * document_count
      postage_total = postage ? @transaction[:postage_cost] : 0
      total_cost = document_total + postage_total

      if @transaction[:document_types].present?
        if document_type.present?
          document_type_label = @transaction[:document_types][document_type]
        end
        raise InvalidDocumentType unless document_type_label
      end

      item_list = "#{document_count} " + pluralize_document_type_label(document_count, document_type_label || "document")
      item_list << ", plus postage," if postage

      return OpenStruct.new(:total_cost => total_cost, :item_list => item_list)
    end

end
