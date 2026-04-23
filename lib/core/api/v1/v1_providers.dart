import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/auth_providers.dart';
import 'v1_services.dart';

final appointmentsServiceProvider = Provider<AppointmentsService>(
  (ref) => AppointmentsService(ref.read(apiClientProvider)),
);

final catalogServiceProvider = Provider<CatalogService>(
  (ref) => CatalogService(ref.read(apiClientProvider)),
);

final documentsServiceProvider = Provider<DocumentsService>(
  (ref) => DocumentsService(ref.read(apiClientProvider)),
);

final notificationsServiceProvider = Provider<NotificationsService>(
  (ref) => NotificationsService(ref.read(apiClientProvider)),
);

final profileServiceProvider = Provider<ProfileService>(
  (ref) => ProfileService(ref.read(apiClientProvider)),
);

final dentalServiceProvider = Provider<DentalService>(
  (ref) => DentalService(ref.read(apiClientProvider)),
);

// Auto-refreshed data providers — call `ref.invalidate(xProvider)` after a
// mutation to force a refetch.
final appointmentsProvider = FutureProvider.autoDispose(
  (ref) => ref.read(appointmentsServiceProvider).list(),
);

final documentsProvider = FutureProvider.autoDispose(
  (ref) => ref.read(documentsServiceProvider).list(),
);

final notificationsProvider = FutureProvider.autoDispose(
  (ref) => ref.read(notificationsServiceProvider).list(),
);

final profileProvider = FutureProvider.autoDispose(
  (ref) => ref.read(profileServiceProvider).show(),
);

final servicesCatalogProvider = FutureProvider.autoDispose(
  (ref) => ref.read(catalogServiceProvider).services(),
);

final staffProvider = FutureProvider.autoDispose(
  (ref) => ref.read(catalogServiceProvider).staff(),
);

final odontogramProvider = FutureProvider.autoDispose(
  (ref) => ref.read(dentalServiceProvider).odontogram(),
);
