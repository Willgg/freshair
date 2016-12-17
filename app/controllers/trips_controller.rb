class TripsController < ApplicationController
  def index
    options = {}
    options[:origin] = params[:iata_code] if params[:iata_code]
    options[:departure_date] = params[:departure_date] if params[:departure_date]
    options[:duration] = params[:duration] if params[:duration]
    options[:people] = params[:people] if params[:people]
    @flights = Trip.find_cheapest(options)
    @trip    = Trip.new
  end

  def new
    @trip = Trip.new
    @dates = Scraper::dates
  end

  def create
    airport = Airport.find_by(iata: params['trip']['airport'])
    @trip = Trip.new(trip_params)
    @trip.airport = airport
    @trip.save
  end

  private

  def trip_params
    params.require(:trip).permit(:duration, :departure_date, :people)
  end
end
