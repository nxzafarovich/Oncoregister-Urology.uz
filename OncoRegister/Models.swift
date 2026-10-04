import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case ru, uz, en
    var id: String { rawValue }
}

enum Sex: String, CaseIterable, Codable { case male, female }
enum VerificationMethod: String, CaseIterable, Codable { case histology, cytology, clinicalInstrumental, other }
enum BiologicalBehavior: String, CaseIterable, Codable { case malignant, inSitu, uncertain }
enum TreatmentType: String, CaseIterable, Codable { case surgery, intravesical, hormonal, none }
enum ContactStatus: String, CaseIterable, Codable { case alive, deceased, unknown }
enum DiseaseStatus: String, CaseIterable, Codable { case noEvidence, stable, progression, recurrence, unknown }

struct TumorSite: Identifiable, Hashable {
    let id: String
    let ru: String
    let uz: String
    let en: String
    let icd10: String
    let topography: String
}

struct MorphologyOption: Identifiable, Hashable {
    let id: String
    let code: String
    let ru: String
    let uz: String
    let en: String
}

struct OperationOption: Identifiable, Hashable {
    let id: String
    let ru: String
    let uz: String
    let en: String
    let descRU: String
    let descUZ: String
    let descEN: String
}

struct Patient: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var surname: String = ""
    var name: String = ""
    var patronymic: String = ""
    var pinfl: String = ""
    var sex: Sex = .male
    var birthDate: Date = Date()
    var address: String = ""
    var citizenship: String = "Uzbekistan"
    var doctor: String = ""

    var diagnosisDate: Date = Date()
    var tumorSiteID: String = ""
    var icd10: String = ""
    var topography: String = ""
    var morphologyCode: String = ""
    var morphologyText: String = ""
    var verification: VerificationMethod = .histology
    var biologicalBehavior: BiologicalBehavior = .malignant
    var grade: String = ""
    var tStage: String = ""
    var nStage: String = ""
    var mStage: String = ""
    var stage: String = ""

    var treatmentStart: Date? = nil
    var treatmentEnd: Date? = nil
    var treatmentType: TreatmentType = .surgery
    var treatmentDate: Date? = nil
    var operationID: String = ""
    var instillation: String = ""
    var treatmentDescription: String = ""

    var lastContact: Date? = nil
    var contactStatus: ContactStatus = .alive
    var diseaseStatus: DiseaseStatus = .unknown
    var deathDate: Date? = nil
    var deathCause: String = ""

    var fullName: String {
        [surname, name, patronymic].filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.joined(separator: " ")
    }
}

enum Catalog {
    static let doctors: [String] = [
        "Бахадирханов Мухаммадзариф Мухаммад Кабирович",
        "Егоров Александр Борисович",
        "Беляев Андрей Львович",
        "Аюбов Бехзод Алишерович",
        "Рахимбаев Аскар Акрамович",
        "Каюмов Абдурауф Абдумавлянович",
        "Сафаев Ёдгорбек Улугбекович",
        "Дадаханов Нодир Эркинович",
        "Зияев Исмоил Баходырович",
        "Мухтаров Шухрат Турсунович",
        "Насыров Фуркат Рауфович",
        "Закиров Хаёт Камилович",
        "Назаров Джахонгир Азадбекович",
        "Салимов Илхом Джурабаевич",
        "Тухтамишев Музаффар Хикматхужаевич",
        "Усманов Бахром Аббосхонович",
        "Хасанов Аъзам Ибрагимович",
        "Лемищенко Тарас Петрович",
        "Парсегова Людмила Рахимовна",
        "Субботин Марк Борисович",
        "Ганиев Сухроб Закирович",
        "Халилов Руслан Диляверович",
        "Давыдов Данил Валерьевич",
        "Каюмова Полина Мухамадиевна",
        "Хасанов Рустам Раджабович",
        "Шерипбаев Рустам Ботирович",
        "Кудрявцев Сергей Петрович",
        "Фазилов Абдуқодир Абдуқаҳҳор ўғли",
        "Асадуллаев Абдулла Маратович",
        "Ходжиметов Таир Аббасович",
        "Юлдашев Жасур Мансурович",
        "Каххаров Дилмурод Улашович",
        "Латипова Наргиза Саидабидовна",
        "Кариев Сарвар Собитжонович",
        "Рахимов Нодир Маннонович",
        "Шавахабов Шавкат Шанасирович",
        "Кадыров Насыр Умидович",
        "Солиев Турсунхужа Холхужаевич",
        "Абдурахмонов Фаррух Фуркатович",
        "Джамилов Джалол Джамалович",
        "Ходжаев Шахзод Надирович",
        "Кадыров Камолиддин Баходир уғли",
        "Сайдахмедов Аъзам Сайдакмалович",
        "Жумаев Бобуржон Шокирович",
        "Хасанов Мардон Мухаммадикулович",
        "Нуриддинов Хусниддин Зафариддин угли",
        "Абдуфаттаев Улугбек Авазжанович",
        "Низамов Дилшод Фазлитдинович",
        "Рузиева Юлдуз Абдуганиевна",
        "Бекматов Азим Акмалович",
        "Джуманиязов Пулатбек Шухратович",
        "Ниязов Бекзот Шерзотович",
        "Номанов Анвар Абдикарим угли",
        "Каххоров Дилмурод Улаш угли",
        "Хожанязов Шерзот Рузиматович",
        "Касимов Сафо Самугжанович",
        "Турсунов Умид",
        "Рахмонбердиев Хикмат"
    ]

    static let tumorSites: [TumorSite] = [
        .init(id:"prostate", ru:"Предстательная железа", uz:"Prostata bezi", en:"Prostate", icd10:"C61", topography:"C61.9"),
        .init(id:"kidney", ru:"Почка", uz:"Buyrak", en:"Kidney", icd10:"C64", topography:"C64.9"),
        .init(id:"renalPelvis", ru:"Почечная лоханка", uz:"Buyrak jomi", en:"Renal pelvis", icd10:"C65", topography:"C65.9"),
        .init(id:"ureter", ru:"Мочеточник", uz:"Siydik nayi", en:"Ureter", icd10:"C66", topography:"C66.9"),
        .init(id:"bladder", ru:"Мочевой пузырь", uz:"Siydik pufagi", en:"Urinary bladder", icd10:"C67", topography:"C67.9"),
        .init(id:"testis", ru:"Яичко", uz:"Moyak", en:"Testis", icd10:"C62", topography:"C62.9"),
        .init(id:"penis", ru:"Половой член", uz:"Jinsiy olat", en:"Penis", icd10:"C60", topography:"C60.9"),
        .init(id:"adrenal", ru:"Надпочечник", uz:"Buyrak usti bezi", en:"Adrenal gland", icd10:"C74", topography:"C74.9"),
        .init(id:"other", ru:"Другое", uz:"Boshqa", en:"Other", icd10:"", topography:"")
    ]

    static let morphologies: [MorphologyOption] = [
        .init(id:"8140/3", code:"8140/3", ru:"Аденокарцинома, БДУ", uz:"Adenokarsinoma, aniqlanmagan", en:"Adenocarcinoma, NOS"),
        .init(id:"8120/3", code:"8120/3", ru:"Уротелиальная карцинома", uz:"Urotelial karsinoma", en:"Urothelial carcinoma"),
        .init(id:"8310/3", code:"8310/3", ru:"Светлоклеточный почечно-клеточный рак", uz:"Tiniq hujayrali buyrak hujayrali karsinoma", en:"Clear cell renal cell carcinoma"),
        .init(id:"8260/3", code:"8260/3", ru:"Папиллярная аденокарцинома", uz:"Papillyar adenokarsinoma", en:"Papillary adenocarcinoma"),
        .init(id:"8070/3", code:"8070/3", ru:"Плоскоклеточная карцинома", uz:"Yassi hujayrali karsinoma", en:"Squamous cell carcinoma"),
        .init(id:"other", code:"", ru:"Другое / вручную", uz:"Boshqa / qo'lda", en:"Other / manual")
    ]

    static let operations: [OperationOption] = [
        .init(id:"rarp", ru:"Робот-ассистированная радикальная простатэктомия", uz:"Robot-assistirlangan radikal prostatektomiya", en:"Robot-assisted radical prostatectomy",
              descRU:"Выполнена робот-ассистированная радикальная простатэктомия — удаление предстательной железы с семенными пузырьками с формированием везикоуретрального анастомоза. Объём лимфодиссекции и дополнительные этапы уточняются в операционном протоколе.",
              descUZ:"Robot-assistirlangan radikal prostatektomiya bajarildi — prostata bezi urug‘ pufakchalari bilan olib tashlandi va vezikouretral anastomoz shakllantirildi. Limfodisseksiya hajmi va qo‘shimcha bosqichlar operatsiya bayonnomasida aniqlashtiriladi.",
              descEN:"Robot-assisted radical prostatectomy was performed — removal of the prostate with seminal vesicles and creation of a vesicourethral anastomosis. The extent of lymph-node dissection and additional steps are specified in the operative report."),
        .init(id:"radNeph", ru:"Радикальная нефрэктомия", uz:"Radikal nefrektomiya", en:"Radical nephrectomy",
              descRU:"Выполнена радикальная нефрэктомия. Детали доступа, объём лимфодиссекции и дополнительные этапы указываются в операционном протоколе.",
              descUZ:"Radikal nefrektomiya bajarildi. Kirish usuli, limfodisseksiya hajmi va qo‘shimcha bosqichlar operatsiya bayonnomasida ko‘rsatiladi.",
              descEN:"Radical nephrectomy was performed. Approach, lymph-node dissection and additional steps are detailed in the operative report."),
        .init(id:"partialNeph", ru:"Резекция почки", uz:"Buyrak rezeksiyasi", en:"Partial nephrectomy",
              descRU:"Выполнена органосохраняющая резекция почки с удалением опухолевого образования. Детали ишемии, гемостаза и реконструкции указываются в операционном протоколе.",
              descUZ:"O‘sma olib tashlanib, buyrakni saqlovchi rezeksiya bajarildi. Ishemiya, gemostaz va rekonstruksiya tafsilotlari operatsiya bayonnomasida ko‘rsatiladi.",
              descEN:"Nephron-sparing partial nephrectomy with tumor excision was performed. Ischemia, hemostasis and reconstruction details are specified in the operative report."),
        .init(id:"cystectomy", ru:"Радикальная цистэктомия", uz:"Radikal sistektomiya", en:"Radical cystectomy",
              descRU:"Выполнена радикальная цистэктомия. Вариант деривации мочи и объём лимфодиссекции указываются в операционном протоколе.",
              descUZ:"Radikal sistektomiya bajarildi. Siydik derivatsiyasi turi va limfodisseksiya hajmi operatsiya bayonnomasida ko‘rsatiladi.",
              descEN:"Radical cystectomy was performed. Urinary diversion and lymph-node dissection are specified in the operative report."),
        .init(id:"nephroureterectomy", ru:"Нефроуретерэктомия", uz:"Nefroureterektomiya", en:"Nephroureterectomy",
              descRU:"Выполнена нефроуретерэктомия. Детали удаления дистального отдела мочеточника и манжеты мочевого пузыря указываются в операционном протоколе.",
              descUZ:"Nefroureterektomiya bajarildi. Siydik nayining distal qismi va siydik pufagi manjetini olib tashlash tafsilotlari operatsiya bayonnomasida ko‘rsatiladi.",
              descEN:"Nephroureterectomy was performed. Details of distal ureter and bladder cuff management are specified in the operative report."),
        .init(id:"turbt", ru:"ТУР опухоли мочевого пузыря (TURBT)", uz:"Siydik pufagi o‘smasining TUR (TURBT)", en:"TURBT",
              descRU:"Выполнена трансуретральная резекция опухоли мочевого пузыря. Локализация, количество очагов, глубина резекции и наличие мышечного слоя уточняются в операционном протоколе и морфологическом заключении.",
              descUZ:"Siydik pufagi o‘smasining transuretral rezeksiyasi bajarildi. Lokalizatsiya, o‘choqlar soni, rezeksiya chuqurligi va mushak qavati mavjudligi operatsiya bayonnomasi va morfologik xulosada aniqlashtiriladi.",
              descEN:"Transurethral resection of bladder tumor was performed. Tumor location, number, resection depth and muscularis propria status are specified in the operative and pathology reports."),
        .init(id:"orchiectomy", ru:"Радикальная орхифуникулэктомия", uz:"Radikal orxifunikulektomiya", en:"Radical orchiectomy",
              descRU:"Выполнена радикальная орхифуникулэктомия паховым доступом. Детали операции указываются в операционном протоколе.",
              descUZ:"Chov kirish yo‘li orqali radikal orxifunikulektomiya bajarildi. Operatsiya tafsilotlari bayonnomada ko‘rsatiladi.",
              descEN:"Radical inguinal orchiectomy was performed. Procedure details are specified in the operative report."),
        .init(id:"other", ru:"Другая операция", uz:"Boshqa operatsiya", en:"Other operation", descRU:"", descUZ:"", descEN:"")
    ]

    static let instillations = ["БЦЖ-инстилляция", "Инстилляция митомицина", "Инстилляция гемцитабина", "Другая внутрипузырная инстилляция"]
    static let tStages = ["", "TX","T0","Tis","T1","T1a","T1b","T2","T2a","T2b","T2c","T3","T3a","T3b","T3c","T4"]
    static let nStages = ["", "NX","N0","N1","N2","N3"]
    static let mStages = ["", "MX","M0","M1"]
    static let stages = ["", "I","II","III","IV","Не определена"]
}
