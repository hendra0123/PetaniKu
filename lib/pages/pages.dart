import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:get_phone_number/get_phone_number.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petaniku/data/response/status.dart';
import 'package:petaniku/models/models.dart';
import 'package:petaniku/shared/shared.dart';
import 'package:petaniku/view_model/view_model.dart';
import 'package:petaniku/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

part 'login_page.dart';
part 'signup_page.dart';
part 'history_page.dart';
part 'formplant_page.dart';
part 'dashboard_page.dart';
part 'camera_page.dart';
part 'map_page.dart';
