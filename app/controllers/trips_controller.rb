class TripsController < ApplicationController
  def index
    options = {}
    options[:origin] = params[:iata_code] if params[:iata_code]
    options[:departure_date] = params[:departure_date] if params[:departure_date]
    options[:duration] = params[:duration] if params[:duration]
    options[:people] = params[:people] if params[:people]
    @flights = Trip.find_cheapest(options)
  end

  def new
    @trip = Trip.new
    @dates = [Scraper::date_of_next('Friday'), Scraper::date_of_next('Saturday')]
  end
end
