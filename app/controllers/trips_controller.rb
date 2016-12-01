class TripsController < ApplicationController
  def index
    service = AmadeusService.new(params[:iata_code])
    @result  = service.get_inspiration
  end

  def new
    @trip = Trip.new
  end
end
