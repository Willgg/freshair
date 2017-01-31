class TripsController < ApplicationController
  def index
    opts = {}
    opts[:origin] = params[:iata] if params[:iata]
    opts[:departure_date] = params[:departure] if params[:departure]
    opts[:duration] = params[:days] if params[:days]
    opts[:people] = params[:people] if params[:people]
    @flights = Trip.find_cheapest(opts)
    @trip = Trip.new
    cities = []
    @flights.each { |r| cities << r['destination'] }
    @weather = Weather::OpenWeather.filtered_forecast(
                 Date.parse(params[:departure]),
                 Date.parse(params[:departure]) + params[:days].to_i.days,
                 cities)
  end

  def new
    @trip = Trip.new
    @dates = Scraper::dates
    @mixpanel_tracker.track('visitor', 'Home page')
  end

  private

  def trip_params
    params.require(:trip).permit(:duration, :departure_date, :people)
  end
end
