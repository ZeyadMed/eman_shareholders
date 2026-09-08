import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:eman_shareholders/core/enum/snack_bar_enum.dart';
import 'package:eman_shareholders/core/local_storage/local_storage.dart';
import 'package:eman_shareholders/core/service_locator/auth_service_locator/auth_service_locator.dart';
import 'package:eman_shareholders/core/service_locator/statement_service_locator/statement_service_locator.dart';
import 'package:eman_shareholders/core/session/session_manager.dart';
import 'package:eman_shareholders/core/service_locator/theme_service_locator/theme_service_locator.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../extensions/extensions.dart';

import 'package:get_it/get_it.dart';

import '../../main.dart';
import '../helpers/helpers.dart';
import '../http/http.dart';
part 'init/init.dart';
part 'shared_service_locator/shared_service_locator.dart';
part 'hive_service_locator/hive_service_locator.dart';
