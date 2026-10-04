import Foundation
import SQLite3

enum DBError: Error, LocalizedError {
    case open(String), exec(String), duplicatePINFL, decode
    var errorDescription: String? {
        switch self {
        case .open(let s): return "Database open error: \(s)"
        case .exec(let s): return "Database error: \(s)"
        case .duplicatePINFL: return "Пациент с таким ПИНФЛ уже зарегистрирован."
        case .decode: return "Patient data could not be decoded."
        }
    }
}

final class DatabaseManager: ObservableObject {
    static let shared = DatabaseManager()

    @Published var patients: [Patient] = []
    @Published var databasePath: String = ""

    private var db: OpaquePointer?
    private let fm = FileManager.default
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let dateFormatter: ISO8601DateFormatter = ISO8601DateFormatter()
    private var rootFolder: URL!
    private var dataFolder: URL!
    private var dbURL: URL!
    private var lockURL: URL!

    private init() {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func start() throws {
        rootFolder = Bundle.main.bundleURL.deletingLastPathComponent()
        dataFolder = rootFolder.appendingPathComponent("Onco Register Data", isDirectory: true)
        let exports = rootFolder.appendingPathComponent("Onco Register Exports", isDirectory: true)
        let backups = rootFolder.appendingPathComponent("Onco Register Backups", isDirectory: true)
        try fm.createDirectory(at: dataFolder, withIntermediateDirectories: true)
        try fm.createDirectory(at: exports, withIntermediateDirectories: true)
        try fm.createDirectory(at: backups, withIntermediateDirectories: true)

        dbURL = dataFolder.appendingPathComponent("onco_register.sqlite")
        lockURL = dataFolder.appendingPathComponent(".onco_write_lock", isDirectory: true)
        databasePath = dbURL.path

        if sqlite3_open_v2(dbURL.path, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, nil) != SQLITE_OK {
            throw DBError.open(errorMessage)
        }
        // Network-share friendly: do not use WAL on SMB/NFS.
        try exec("PRAGMA journal_mode=DELETE;")
        try exec("PRAGMA synchronous=FULL;")
        try exec("PRAGMA busy_timeout=15000;")
        try exec("PRAGMA foreign_keys=ON;")
        try exec("""
        CREATE TABLE IF NOT EXISTS patients(
            id TEXT PRIMARY KEY,
            pinfl TEXT NOT NULL UNIQUE,
            full_name TEXT NOT NULL,
            diagnosis_date TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            json BLOB NOT NULL
        );
        """)
        try exec("CREATE INDEX IF NOT EXISTS idx_patients_name ON patients(full_name);")
        try exec("CREATE INDEX IF NOT EXISTS idx_patients_diag_date ON patients(diagnosis_date);")
        try reload()
    }

    deinit { if db != nil { sqlite3_close(db) } }

    private var errorMessage: String {
        if let db, let c = sqlite3_errmsg(db) { return String(cString: c) }
        return "Unknown database error"
    }

    private func exec(_ sql: String) throws {
        var err: UnsafeMutablePointer<Int8>?
        if sqlite3_exec(db, sql, nil, nil, &err) != SQLITE_OK {
            let msg = err.map { String(cString:$0) } ?? errorMessage
            sqlite3_free(err)
            throw DBError.exec(msg)
        }
    }

    private func withNetworkWriteLock<T>(_ block: () throws -> T) throws -> T {
        let deadline = Date().addingTimeInterval(20)
        while true {
            do {
                try fm.createDirectory(at: lockURL, withIntermediateDirectories: false)
                break
            } catch {
                // Clear stale lock older than 90 seconds.
                if let attrs = try? fm.attributesOfItem(atPath: lockURL.path),
                   let d = attrs[.modificationDate] as? Date,
                   Date().timeIntervalSince(d) > 90 {
                    try? fm.removeItem(at: lockURL)
                    continue
                }
                if Date() > deadline { throw DBError.exec("Database is busy. Try again in a few seconds.") }
                Thread.sleep(forTimeInterval: 0.15)
            }
        }
        defer { try? fm.removeItem(at: lockURL) }
        return try block()
    }

    func reload() throws {
        guard let db else { return }
        var stmt: OpaquePointer?
        let sql = "SELECT json FROM patients ORDER BY diagnosis_date DESC, updated_at DESC;"
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { throw DBError.exec(errorMessage) }
        defer { sqlite3_finalize(stmt) }
        var result: [Patient] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            guard let bytes = sqlite3_column_blob(stmt, 0) else { continue }
            let len = Int(sqlite3_column_bytes(stmt, 0))
            let data = Data(bytes: bytes, count: len)
            if let p = try? decoder.decode(Patient.self, from: data) { result.append(p) }
        }
        DispatchQueue.main.async { self.patients = result }
    }

    func save(_ patient: Patient) throws {
        try withNetworkWriteLock {
            var p = patient
            p.updatedAt = Date()
            let data = try encoder.encode(p)
            try exec("BEGIN IMMEDIATE;")
            do {
                // explicit duplicate check
                var check: OpaquePointer?
                let csql = "SELECT id FROM patients WHERE pinfl=? AND id<>? LIMIT 1;"
                guard sqlite3_prepare_v2(db, csql, -1, &check, nil) == SQLITE_OK else { throw DBError.exec(errorMessage) }
                sqlite3_bind_text(check, 1, p.pinfl, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(check, 2, p.id.uuidString, -1, SQLITE_TRANSIENT)
                let dup = sqlite3_step(check) == SQLITE_ROW
                sqlite3_finalize(check)
                if dup { throw DBError.duplicatePINFL }

                var stmt: OpaquePointer?
                let sql = """
                INSERT INTO patients(id,pinfl,full_name,diagnosis_date,updated_at,json)
                VALUES(?,?,?,?,?,?)
                ON CONFLICT(id) DO UPDATE SET
                  pinfl=excluded.pinfl,
                  full_name=excluded.full_name,
                  diagnosis_date=excluded.diagnosis_date,
                  updated_at=excluded.updated_at,
                  json=excluded.json;
                """
                guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { throw DBError.exec(errorMessage) }
                sqlite3_bind_text(stmt, 1, p.id.uuidString, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 2, p.pinfl, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 3, p.fullName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 4, dateFormatter.string(from: p.diagnosisDate), -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 5, dateFormatter.string(from: p.updatedAt), -1, SQLITE_TRANSIENT)
                data.withUnsafeBytes { ptr in
                    sqlite3_bind_blob(stmt, 6, ptr.baseAddress, Int32(data.count), SQLITE_TRANSIENT)
                }
                guard sqlite3_step(stmt) == SQLITE_DONE else {
                    sqlite3_finalize(stmt)
                    throw DBError.exec(errorMessage)
                }
                sqlite3_finalize(stmt)
                try exec("COMMIT;")
            } catch {
                try? exec("ROLLBACK;")
                throw error
            }
        }
        try reload()
    }

    func createBackup() throws -> URL {
        let backups = rootFolder.appendingPathComponent("Onco Register Backups", isDirectory: true)
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dest = backups.appendingPathComponent("OncoRegister_\(f.string(from: Date())).sqlite")
        return try withNetworkWriteLock {
            var out: OpaquePointer?
            guard sqlite3_open(dest.path, &out) == SQLITE_OK else { throw DBError.open("Backup destination") }
            defer { sqlite3_close(out) }
            guard let backup = sqlite3_backup_init(out, "main", db, "main") else { throw DBError.exec("Backup init failed") }
            sqlite3_backup_step(backup, -1)
            sqlite3_backup_finish(backup)
            return dest
        }
    }

    func exportSpreadsheetML(year: Int, month: Int, language: LanguageStore) throws -> URL {
        try reload()
        let cal = Calendar.current
        let selected = patients.filter {
            cal.component(.year, from: $0.diagnosisDate) == year &&
            cal.component(.month, from: $0.diagnosisDate) == month
        }
        let headers = ["№","Ф.И.О.","ПИНФЛ / JShShIR","Дата рождения","Пол","Адрес","Гражданство",
                       "Дата диагноза","Локализация","МКБ-10","ICD-O-3 Topography","Морфология / гистология",
                       "ICD-O-3 Morphology","Метод подтверждения","Биологическое поведение","Дифференцировка",
                       "T","N","M","Стадия","Дата начала лечения","Дата окончания лечения","Вид лечения",
                       "Операция / инстилляция","Дата воздействия","Описание лечения","Последний контакт",
                       "Состояние","Статус заболевания","Дата смерти","Причина смерти","Лечащий врач"]
        let df = DateFormatter(); df.dateFormat = "dd.MM.yyyy"
        func esc(_ s:String)->String { s.replacingOccurrences(of:"&",with:"&amp;").replacingOccurrences(of:"<",with:"&lt;").replacingOccurrences(of:">",with:"&gt;") }
        func cell(_ s:String)->String { "<Cell><Data ss:Type=\"String\">\(esc(s))</Data></Cell>" }
        var rows = "<Row>" + headers.map(cell).joined() + "</Row>"
        for (i,p) in selected.enumerated() {
            let site = Catalog.tumorSites.first{$0.id == p.tumorSiteID}
            let op = Catalog.operations.first{$0.id == p.operationID}
            let vals:[String] = [
                "\(i+1)", p.fullName, p.pinfl, df.string(from:p.birthDate), language.enumLabel(p.sex.rawValue),
                p.address,p.citizenship,df.string(from:p.diagnosisDate),site.map(language.siteName) ?? "",
                p.icd10,p.topography,p.morphologyText,p.morphologyCode,language.enumLabel(p.verification.rawValue),
                language.enumLabel(p.biologicalBehavior.rawValue),p.grade,p.tStage,p.nStage,p.mStage,p.stage,
                p.treatmentStart.map(df.string) ?? "",p.treatmentEnd.map(df.string) ?? "",language.enumLabel(p.treatmentType.rawValue),
                p.treatmentType == .surgery ? (op.map(language.operationName) ?? "") : p.instillation,
                p.treatmentDate.map(df.string) ?? "",p.treatmentDescription,p.lastContact.map(df.string) ?? "",
                language.enumLabel(p.contactStatus.rawValue),language.enumLabel(p.diseaseStatus.rawValue),
                p.deathDate.map(df.string) ?? "",p.deathCause,p.doctor
            ]
            rows += "<Row>" + vals.map(cell).joined() + "</Row>"
        }
        let xml = """
        <?xml version="1.0"?>
        <?mso-application progid="Excel.Sheet"?>
        <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
          xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">
          <Worksheet ss:Name="Onco Register"><Table>\(rows)</Table></Worksheet>
        </Workbook>
        """
        let exports = rootFolder.appendingPathComponent("Onco Register Exports", isDirectory: true)
        let dest = exports.appendingPathComponent(String(format:"Onco_Register_%04d_%02d.xls",year,month))
        try xml.data(using:.utf8)!.write(to:dest, options:.atomic)
        return dest
    }
}
