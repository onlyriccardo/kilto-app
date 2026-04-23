/// Riverpod providers for the staff-facing /v1/clinic/* endpoints.
///
/// Mirrors the shape of v1_providers.dart: a Provider<Service> per service
/// class plus FutureProvider.autoDispose for each data stream. Invalidate
/// the data providers after mutations (`ref.invalidate(clinicDashboardProvider)`).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/auth_providers.dart';
import 'clinic_services.dart';

// ── Services ──
final clinicDashboardServiceProvider = Provider<ClinicDashboardService>(
  (ref) => ClinicDashboardService(ref.read(apiClientProvider)),
);

final clinicAgendaServiceProvider = Provider<ClinicAgendaService>(
  (ref) => ClinicAgendaService(ref.read(apiClientProvider)),
);

final clinicPatientsServiceProvider = Provider<ClinicPatientsService>(
  (ref) => ClinicPatientsService(ref.read(apiClientProvider)),
);

final clinicMessagingServiceProvider = Provider<ClinicMessagingService>(
  (ref) => ClinicMessagingService(ref.read(apiClientProvider)),
);

final clinicDirectoryServiceProvider = Provider<ClinicDirectoryService>(
  (ref) => ClinicDirectoryService(ref.read(apiClientProvider)),
);

// ── Data providers ──

final clinicDashboardProvider = FutureProvider.autoDispose(
  (ref) => ref.read(clinicDashboardServiceProvider).fetch(),
);

/// Agenda keyed by date string (YYYY-MM-DD). Pass null for today.
final clinicAgendaProvider = FutureProvider.autoDispose.family<
    Map<String, dynamic>, String?>(
  (ref, date) => ref.read(clinicAgendaServiceProvider).byDate(date: date),
);

/// Patients list — family keyed by (filter, query).
class PatientsQuery {
  final String filter;
  final String query;
  const PatientsQuery({this.filter = 'all', this.query = ''});
  @override
  bool operator ==(Object o) =>
      o is PatientsQuery && o.filter == filter && o.query == query;
  @override
  int get hashCode => Object.hash(filter, query);
}

final clinicPatientsProvider = FutureProvider.autoDispose.family<
    List<Map<String, dynamic>>, PatientsQuery>(
  (ref, q) => ref
      .read(clinicPatientsServiceProvider)
      .list(filter: q.filter, query: q.query),
);

final clinicPatientDetailProvider = FutureProvider.autoDispose.family<
    Map<String, dynamic>, int>(
  (ref, id) => ref.read(clinicPatientsServiceProvider).show(id),
);

final clinicConversationsProvider = FutureProvider.autoDispose(
  (ref) => ref.read(clinicMessagingServiceProvider).conversations(),
);

final clinicConversationMessagesProvider = FutureProvider.autoDispose.family<
    Map<String, dynamic>, int>(
  (ref, conversationId) =>
      ref.read(clinicMessagingServiceProvider).messages(conversationId),
);

final clinicTeamProvider = FutureProvider.autoDispose(
  (ref) => ref.read(clinicDirectoryServiceProvider).team(),
);

final clinicServicesProvider = FutureProvider.autoDispose(
  (ref) => ref.read(clinicDirectoryServiceProvider).services(),
);

final clinicSettingsProvider = FutureProvider.autoDispose(
  (ref) => ref.read(clinicDirectoryServiceProvider).settings(),
);

final clinicFinancesProvider = FutureProvider.autoDispose(
  (ref) => ref.read(clinicDirectoryServiceProvider).finances(),
);

final clinicCampaignsProvider = FutureProvider.autoDispose(
  (ref) => ref.read(clinicDirectoryServiceProvider).campaigns(),
);

final clinicNotificationsProvider = FutureProvider.autoDispose(
  (ref) => ref.read(clinicDirectoryServiceProvider).notifications(),
);
