import 'dart:io';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:petaniku/data/response/api_response.dart';
import 'package:petaniku/data/response/status.dart';
import 'package:petaniku/models/models.dart';
import 'package:petaniku/repository/repository.dart';

part 'user_view_model.dart';
part 'history_view_model.dart';
part 'prediction_view_model.dart';

bool hasDataChanged = true;
