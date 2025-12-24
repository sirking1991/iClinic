import 'package:drift/drift.dart';

class Patients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fullName => text().withLength(min: 1, max: 100)();
  TextColumn get gender => text()(); // 'Male', 'Female', 'Other'
  DateTimeColumn get birthDate => dateTime()();
  TextColumn get bloodType => text().nullable()();
  TextColumn get photoPath => text().nullable()(); // Local path

  // Contact & Meta
  TextColumn get phoneNumber => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Consultations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id)();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();

  TextColumn get subjectiveNotes => text().nullable()();
  TextColumn get objectiveNotes => text().nullable()();
  TextColumn get assessment => text().nullable()();
  TextColumn get plan => text().nullable()();
}

// "Stream" Items (The chat-like history)
class StreamEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get consultationId => integer().references(Consultations, #id)();
  TextColumn get type => text()(); // 'note', 'vitals', 'rx', 'lab'
  TextColumn get contentJson => text()(); // JSON payload for flexibility
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  TextColumn get authorName => text()();
}

class Prescriptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get consultationId => integer().references(Consultations, #id)();
  TextColumn get drugName => text()();
  TextColumn get dosage => text()();
  TextColumn get frequency => text()();
  TextColumn get duration => text()();
  DateTimeColumn get issuedAt => dateTime().withDefault(currentDateAndTime)();
}

class AuditLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get action =>
      text()(); // 'USER_LOGIN', 'VIEW_PATIENT', 'EDIT_NOTE'
  TextColumn get details => text().nullable()();
  TextColumn get userId => text()(); // 'user_123'
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

class Appointments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id)();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get reason => text().nullable()();
  TextColumn get status => text().withDefault(
    const Constant('scheduled'),
  )(); // scheduled, cancelled, completed
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Doctors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fullName => text().withLength(min: 1, max: 100)();
  TextColumn get specialization => text().nullable()();
  TextColumn get pin => text().withLength(min: 4, max: 4)(); // 4-digit PIN
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
