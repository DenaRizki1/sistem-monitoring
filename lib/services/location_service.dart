import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../utils/helpers.dart';

class LocationService {
  static final LocationService instance = LocationService._();

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  final LocationSettings _locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.best,
    intervalDuration: const Duration(seconds: 1),
    timeLimit: const Duration(minutes: 1),
  );

  LocationService._();

  Future<Position?> getCurrentLocation(BuildContext context) async {
    final hasPermission = await _handlePermission();

    switch (hasPermission) {
      case 1:
        showDialogOpenGps(context);
        return null;

      case 2:
        return null;

      case 3:
        showDialogOpenSettingPermission(context);
        return null;

      default:
        try {
          Position position = await _geolocatorPlatform.getCurrentPosition(locationSettings: _locationSettings);
          // if (position.isMocked) {
          //   showToast("Anda terdeteksi menggunakan lokasi palsu");
          // }
          return position;
        } catch (e) {
          log(e.toString());
          showToast("Tidak dapat mendapatakan lokasi anda");
          return null;
        }
    }
  }

  Future<int> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      log("GPS off");

      return 1;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        log("denied permission");

        return 2;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      log("denied foverefer permission");
      return 3;
    }

    log("grand permission");
    return 0;
  }
}
