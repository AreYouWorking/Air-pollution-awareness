class UserPosition {
  static String displayPlaceGPS = '';
  static String latitudeGPS = '';
  static String longitudeGPS = '';

  static String displayPlaceChosen = '';
  static String latitudeChosen = '';
  static String longitudeChosen = '';

  // Location Bias  proximity for find place near user
  static String proximityLatitude = '';
  static String proximityLongitude = '';

  static void setCurrentLocation(String lat, String lon, String placeName) {
    latitudeGPS = lat;
    longitudeGPS = lon;
    proximityLatitude = lat;
    proximityLongitude = lon;
    displayPlaceGPS = placeName;

    if (latitudeChosen == '') setChosenLocation(lat, lon, placeName);
  }

  static void setChosenLocation(String lat, String lon, String placeName) {
    latitudeChosen = lat;
    longitudeChosen = lon;
    displayPlaceChosen = placeName;
  }
}
