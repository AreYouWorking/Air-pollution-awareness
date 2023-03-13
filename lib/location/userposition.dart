class Userposition {
  static String display_place_GPS = '';
  static String latitudeGPS = '';
  static String longitudeGPS = '';

  static String display_place_Chosen = '';
  static String latitudeChosen = '';
  static String longitudeChosen = '';

  // Location Bias  proximity for find place near user
  static String proximity_latitude = '';
  static String proximity_longitude = '';

  static void setCurrentLocation(String lat, String lon, String placeName) {
    latitudeGPS = lat;
    longitudeGPS = lon;
    proximity_latitude = lat;
    proximity_longitude = lon;
    display_place_GPS = placeName;

    if (latitudeChosen == '') setChosenLocation(lat, lon, placeName);
  }

  static void setChosenLocation(String lat, String lon, String placeName) {
    latitudeChosen = lat;
    longitudeChosen = lon;
    display_place_Chosen = placeName;
  }
}
