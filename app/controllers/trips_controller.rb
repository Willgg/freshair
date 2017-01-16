class TripsController < ApplicationController
  def index
    options = {}
    options[:origin] = params[:iata_code] if params[:iata_code]
    options[:departure_date] = params[:departure_date] if params[:departure_date]
    options[:duration] = params[:duration] if params[:duration]
    options[:people] = params[:people] if params[:people]
    @flights = Trip.find_cheapest(options)
    @trip    = Trip.new
    @weather = Weather.new(JSON.parse($redis.get('weather')))
    cities = []
    @flights.each { |r| cities << r['destination'] }
    @weather = @weather.avg_temperature(cities, Date.parse(options[:departure_date]), Date.parse(options[:departure_date]) + options[:duration].to_i.days)
  end

  def new
    @trip = Trip.new
    @dates = Scraper::dates
  end

  private

  def trip_params
    params.require(:trip).permit(:duration, :departure_date, :people)
  end
end
