Calagator.setup do |config|
  # Site's name
  config.title = 'Calagator'

  # Site's tagline
  config.tagline = "Portland's Tech Calendar"

  # Site's URL with trailing slash
  config.url = 'http://calagator.org/'

  # Map to display on /venues page:
  config.venues_map_options = {
    # Zoom magnification level:
    zoom: 12,
    # Center of the map, in latitude and longitude.
    # If no center is specified, the map will zoom to fit all markers.
    center: [45.518493, -122.660737]
  }

end
