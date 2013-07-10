class Transaction < OpenStruct

  class TransactionNotFound < StandardError; end
  class InvalidDocumentType < StandardError; end
  class InvalidPostageOption < StandardError; end
  class InvalidDocumentCount < StandardError; end
  class InvalidRegistrationCount < StandardError; end

  PARAMPLUS_KEYS = ['document_count', 'postage', 'postage_option', 'registration_count']

  def calculate_total(values)
    calculator = TransactionCalculator.new(self)
    calculator.calculate(values)
  end

  def self.find(id)
    if transaction = self.transaction_list[id]
      Transaction.new(transaction.merge('slug' => id))
    else
      raise TransactionNotFound
    end
  end

  cattr_writer :file_path, :transaction_list

  def self.file_path
    @@file_path || Rails.root.join("lib/transactions.yml")
  end

  def self.transaction_list
    @@transaction_list ||= self.load_transaction_list
  end

  # To support subdomain routing (see routes.rb)
  def self.matches?(request)
    slug = request.subdomains(0).first
    transaction_list.has_key?(slug)
  end

  private

  def self.load_transaction_list
    YAML.load( File.open( self.file_path ) )
  end
end
