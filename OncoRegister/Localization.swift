import Foundation
import SwiftUI

final class LanguageStore: ObservableObject {
    @Published var language: AppLanguage = .ru
    func t(_ key: String) -> String {
        let table: [String:[AppLanguage:String]] = [
            "center":[.ru:"Республиканский специализированный научно-практический медицинский центр урологии",
                      .uz:"Respublika ixtisoslashtirilgan urologiya ilmiy-amaliy tibbiyot markazi",
                      .en:"Republican Specialized Scientific-Practical Medical Center of Urology"],
            "newPatient":[.ru:"Новый пациент",.uz:"Yangi bemor",.en:"New patient"],
            "patients":[.ru:"База пациентов",.uz:"Bemorlar bazasi",.en:"Patient database"],
            "export":[.ru:"Экспорт в Excel",.uz:"Excelga eksport",.en:"Export to Excel"],
            "backup":[.ru:"Резервная копия",.uz:"Zaxira nusxa",.en:"Backup"],
            "search":[.ru:"Найти пациента по ПИНФЛ / Ф.И.О.",.uz:"JShShIR / F.I.Sh. bo‘yicha qidirish",.en:"Find patient by PINFL / full name"],
            "save":[.ru:"Сохранить",.uz:"Saqlash",.en:"Save"],
            "savePrint":[.ru:"Сохранить и распечатать",.uz:"Saqlash va chop etish",.en:"Save and print"],
            "cancel":[.ru:"Отмена",.uz:"Bekor qilish",.en:"Cancel"],
            "creatorLabel":[.ru:"Создатель",.uz:"Yaratuvchi",.en:"Created by"],
            "creator":[.ru:"Нуриддинов Хусниддин Зафариддин угли",
                       .uz:"Nuriddinov Xusniddin Zafariddin o'g'li",
                       .en:"Nuriddinov Khusniddin Zafariddin ugli"],
            "sharedDB":[.ru:"Общая база",.uz:"Umumiy baza",.en:"Shared database"],
            "databaseWarning":[.ru:"База хранится рядом с приложением в общей сетевой папке.",
                               .uz:"Baza dastur yonidagi umumiy tarmoq papkasida saqlanadi.",
                               .en:"The database is stored next to the app in the shared network folder."]
        ]
        return table[key]?[language] ?? key
    }

    func enumLabel(_ raw: String) -> String {
        let m: [String:[AppLanguage:String]] = [
            "male":[.ru:"Мужской",.uz:"Erkak",.en:"Male"],
            "female":[.ru:"Женский",.uz:"Ayol",.en:"Female"],
            "histology":[.ru:"Гистологический",.uz:"Gistologik",.en:"Histological"],
            "cytology":[.ru:"Цитологический",.uz:"Sitologik",.en:"Cytological"],
            "clinicalInstrumental":[.ru:"Клинико-инструментальный",.uz:"Klinik-instrumental",.en:"Clinical/instrumental"],
            "other":[.ru:"Другой",.uz:"Boshqa",.en:"Other"],
            "malignant":[.ru:"Злокачественное",.uz:"Xavfli",.en:"Malignant"],
            "inSitu":[.ru:"In situ",.uz:"In situ",.en:"In situ"],
            "uncertain":[.ru:"Неопределённое",.uz:"Noaniq",.en:"Uncertain"],
            "surgery":[.ru:"Хирургическое лечение",.uz:"Jarrohlik davolash",.en:"Surgery"],
            "intravesical":[.ru:"Внутрипузырная инстилляция",.uz:"Qovuq ichiga instillyatsiya",.en:"Intravesical instillation"],
            "hormonal":[.ru:"Гормональная терапия",.uz:"Gormonal terapiya",.en:"Hormonal therapy"],
            "none":[.ru:"Специальное лечение не проводилось",.uz:"Maxsus davolash o‘tkazilmagan",.en:"No specific treatment"],
            "alive":[.ru:"Жив",.uz:"Tirik",.en:"Alive"],
            "deceased":[.ru:"Умер",.uz:"Vafot etgan",.en:"Deceased"],
            "unknown":[.ru:"Нет данных",.uz:"Ma’lumot yo‘q",.en:"Unknown"],
            "noEvidence":[.ru:"Без признаков заболевания",.uz:"Kasallik belgilari yo‘q",.en:"No evidence of disease"],
            "stable":[.ru:"Стабилизация",.uz:"Stabilizatsiya",.en:"Stable disease"],
            "progression":[.ru:"Прогрессирование",.uz:"Progressiya",.en:"Progression"],
            "recurrence":[.ru:"Рецидив",.uz:"Retsidiv",.en:"Recurrence"]
        ]
        return m[raw]?[language] ?? raw
    }

    func siteName(_ site: TumorSite) -> String {
        switch language { case .ru: return site.ru; case .uz: return site.uz; case .en: return site.en }
    }
    func morphologyName(_ m: MorphologyOption) -> String {
        switch language { case .ru: return m.ru; case .uz: return m.uz; case .en: return m.en }
    }
    func operationName(_ o: OperationOption) -> String {
        switch language { case .ru: return o.ru; case .uz: return o.uz; case .en: return o.en }
    }
    func operationDescription(_ o: OperationOption) -> String {
        switch language { case .ru: return o.descRU; case .uz: return o.descUZ; case .en: return o.descEN }
    }
}
