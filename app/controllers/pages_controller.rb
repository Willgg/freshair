class PagesController < ApplicationController
  def home
    @trip = Trip.new
  end
end
