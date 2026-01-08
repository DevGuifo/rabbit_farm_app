import '../models/rituel.dart';
import '../models/anomalie_rituel.dart';
import '../models/journal_entry.dart';
import '../services/database_helper.dart';

/// Repository spécialisé pour les rituels, anomalies et journal
///
/// Gère le suivi opérationnel quotidien.
class RituelRepository {
  static final RituelRepository instance = RituelRepository._init();
  RituelRepository._init();

  final DatabaseHelper _db = DatabaseHelper.instance;

  // ============= CRUD RITUELS =============

  Future<Rituel?> getRituelByDateAndType(DateTime date, String type) =>
      _db.getRituelByDateAndType(date, type);

  Future<Rituel> insertRituel(Rituel rituel) => _db.insertRituel(rituel);

  Future<void> updateRituel(Rituel rituel) => _db.updateRituel(rituel);

  Future<List<Rituel>> getHistoriqueRituels({int limite = 14}) =>
      _db.getHistoriqueRituels(limite: limite);

  // ============= CRUD ANOMALIES =============

  Future<int> insertAnomalie(AnomalieRituel anomalie) =>
      _db.insertAnomalieRituel(anomalie);

  Future<int> updateAnomalie(AnomalieRituel anomalie) =>
      _db.updateAnomalieRituel(anomalie);

  Future<List<AnomalieRituel>> getAnomaliesAujourdhui() =>
      _db.getAnomaliesAujourdhui();

  Future<List<AnomalieRituel>> getAnomaliesNonResolues() =>
      _db.getAnomaliesNonResolues();

  Future<List<AnomalieRituel>> getAnomaliesCritiques() =>
      _db.getAnomaliesCritiques();

  Future<StatsAnomalies> getStatsAnomalies() => _db.getStatsAnomalies();

  // ============= CRUD JOURNAL =============

  Future<int> insertJournalEntry(JournalEntry entry) =>
      _db.insertJournalEntry(entry);

  Future<List<JournalEntry>> getJournalAujourdhui() =>
      _db.getJournalAujourdhui();

  Future<List<JournalEntry>> getJournalSemaine() => _db.getJournalSemaine();

  Future<List<JournalEntry>> getJournalMois() => _db.getJournalMois();

  Future<List<JournalEntry>> getJournalNonLu() => _db.getJournalNonLu();

  Future<void> marquerJournalLu(int id) => _db.marquerJournalLu(id);

  Future<void> marquerToutLu() => _db.marquerToutLu();

  Future<void> ajouterNoteJournal(int id, String note) =>
      _db.ajouterNoteJournal(id, note);

  Future<int> countJournalNonLu() => _db.countJournalNonLu();
}
