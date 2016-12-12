class TripsController < ApplicationController
  def index
    options = {}
    options[:departure_date] = params[:departure_date] if params[:departure_date]
    options[:duration] = params[:duration] if params[:duration]
    @flights = JSON.parse($redis.get(params[:iata_code]))
    @flights = @flights[options[:departure_date]][options[:duration]]
    raise
    # service = AmadeusService.new(params[:iata_code],options)
    # @result  = service.get_inspiration
  end

  def new
    @trip = Trip.new
  end
end
