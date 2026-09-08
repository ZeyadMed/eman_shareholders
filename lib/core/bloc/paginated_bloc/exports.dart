
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eman_shareholders/core/local_storage/local_storage.dart';
import '../../enum/status.dart';
import '../../helpers/helpers.dart';
import '../../http/either.dart';
import '../../http/failure.dart';
import '../../service_locator/service_locator.dart';
part 'paginated_event.dart';
part '../base_state/base_state.dart';
part 'paginated_bloc.dart';
part '../enum_bloc/enum_bloc.dart';
part '../enum_bloc/enum_event.dart';
part '../enum_bloc/enum_state.dart';

