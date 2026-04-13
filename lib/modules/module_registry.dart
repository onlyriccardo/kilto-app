import 'module_interface.dart';
import 'dental/dental_module.dart';

class ModuleRegistry {
  static final Map<String, AppModule> _modules = {
    'dental': DentalModule(),
  };

  static List<AppModule> getActive(List<String> activeIds) {
    return activeIds
        .map((id) => _modules[id])
        .where((m) => m != null)
        .cast<AppModule>()
        .toList();
  }

  static AppModule? get(String id) => _modules[id];
}
