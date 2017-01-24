module TripsHelper

  def weather_icon(code)
    asset_path "#{code}"
  end

end
