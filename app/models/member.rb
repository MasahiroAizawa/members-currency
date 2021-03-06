class Member < ActiveRecord::Base
  attr_accessible :member_id, :name, :profile
  attr_accessor :currency_list

  validates :name, presence: true, length: {maximum: 255}
  validates :profile, presence: true, length: {maximum: 512}

  class << self
    def get(member_id)
      Member.find(:first, conditions: {member_id: member_id})
    end
  end

  def load_data(params)
    self.name = params[:name]
    self.profile = params[:profile]
    self
  end

  def generate_member_id
    self.member_id = Member.all.max{|a, b| a.member_id <=> b.member_id}.member_id + 1
    self
  end

  def set_currency_info(currency)
    self.currency_list ||= []
    currency_id = currency.currency_id
    currency_information = CurrencyInformation.new
    currency_information.id = currency_id
    currency_information.name = currency.name
    currency_information.amount = AmountOfCurrency.get(self.member_id, currency_id).amount
    self.currency_list.push(currency_information)
    self
  end

  def currency_amount(currency_id)
    currency_info = currency_list.find{|currency| currency.id == currency_id}
    currency_info.amount
  end

  def non_publish?
    Currency.find(:all, conditions: {publisher: self.member_id}).blank?
  end

  def deletable?
    distribution_zero?
  end

  def distribution_zero?
    amounts = AmountOfCurrency.find(:all, conditions: {member_id: self.member_id})
    amounts.all?{|amount| amount.amount.zero?}
  end

  def invalid?
    unless self.distribution_zero?
      self.errors[:error] = 'This data can not delete.'
    end
    super
  end

  def give(given_amount, currency)
    operation = CurrencyOperation.new(self, :give)
    operation.target_currency(currency)
    operation.set_amount(given_amount)
    operation
  end

  def save
    super

    Currency.all.each do |currency|
      amount = AmountOfCurrency.new
      amount.amount = 0
      amount.currency_id = currency.currency_id
      amount.member_id = self.member_id
      amount.save
    end
  end

  def exchange(amount)
    exchange_currency = ExchangeCurrency.new(self.member_id, amount)
    exchange_currency
  end

  class CurrencyInformation
    attr_accessor :id
    attr_accessor :name
    attr_accessor :amount
  end

  class CurrencyOperation
    attr_accessor :type, :from, :currency, :to_member, :amount

    def initialize(from_member, type)
      self.from = from_member
      self.type = type
    end

    def target_currency(currency)
      self.currency = currency
    end

    def set_amount(amount)
      self.amount = amount
    end

    def to(member)
      self.to_member = member
      self
    end

    def run
      ## TODO: Add trunsaction code.
      log = LogForCurrency.new
      log.currency_id = self.currency.currency_id
      log.from_member_id = self.from.member_id
      log.to_member_id = self.to_member.member_id
      log.amount = self.amount
      log.operation_date = DateTime.current
      log.log = operation_log

      log.save

      from_amount = AmountOfCurrency.get(self.from.member_id, self.currency.currency_id)
      from_amount.amount -= self.amount.to_i
      from_amount.save

      to_amount = AmountOfCurrency.get(self.to_member.member_id, self.currency.currency_id)
      to_amount.amount += self.amount.to_i
      to_amount.save

      true
    end

    def operation_log
      case self.type
      when :give
        I18n.t('message.give', from: self.from.name, to: self.to_member.name, currency: self.currency.name, amount:self.amount)
      end
    end
  end

  class ExchangeCurrency
    attr_accessor :currency_id, :member_id, :amount

    def initialize(member_id, amount)
      self.member_id = member_id
      self.amount = amount
    end

    def of(currency_id)
      self.currency_id = currency_id
      self
    end

    def run
      member = Member.get(self.member_id)
      currency = Currency.get(self.currency_id)
      ticket_list = MoneyTicket.exchange_tickets(self.amount)

      ticket_list.each do |ticket|
        ticket.status = MoneyTicket::USED
        ticket.used_date = DateTime.current
        ticket.save
      end

      log = LogForCurrency.new
      log.from_member_id = LogForCurrency::SYSTEM_ID
      log.to_member_id = self.member_id
      log.amount = self.amount
      log.operation_date = DateTime.current
      log.currency_id = self.currency_id
      log.log = I18n.t('log.exchange', name: member.name, currency: currency.name, amount: self.amount)
      log.save

      member_amount = AmountOfCurrency.get(self.member_id, self.currency_id)
      member_amount.amount -= self.amount
      member_amount.save
    end
  end
end

