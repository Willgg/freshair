class TripsController < ApplicationController
  def index
    options = {}
    options[:departure_date] = params[:departure_date] if params[:departure_date]
    options[:duration] = params[:duration] if params[:duration]
    service = AmadeusService.new(params[:iata_code],options)
    @result  = service.get_inspiration
  end

  def new
    @trip = Trip.new
  end
end
