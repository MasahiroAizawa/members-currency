class CurrenciesController < ApplicationController
  def index
    @currenies = Currency.all
  end

  def show
    @currency = Currency.find(:first, conditions: {id: params[:id]})
  end
end

