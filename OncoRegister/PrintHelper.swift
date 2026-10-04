import SwiftUI
import AppKit

enum PrintHelper {
    static func printPatient(_ patient: Patient, language: LanguageStore) {
        let view = PatientPrintView(patient: patient).environmentObject(language)
        let host = NSHostingView(rootView: view)
        host.frame = NSRect(x:0,y:0,width:595,height:842) // A4-ish points
        let info = NSPrintInfo.shared
        info.paperSize = NSSize(width:595,height:842)
        info.topMargin = 18; info.bottomMargin = 18; info.leftMargin = 18; info.rightMargin = 18
        info.horizontalPagination = .fit; info.verticalPagination = .fit
        NSPrintOperation(view: host, printInfo: info).run()
    }
}

struct PatientPrintView: View {
    @EnvironmentObject var language: LanguageStore
    let patient: Patient
    let df: DateFormatter = { let f=DateFormatter(); f.dateFormat="dd.MM.yyyy"; return f }()
    var body: some View {
        VStack(alignment:.leading,spacing:7) {
            HStack {
                if let u=Bundle.main.url(forResource:"rscu-logo_light2",withExtension:"png"),
                   let img=NSImage(contentsOf:u) {
                    Image(nsImage:img).resizable().scaledToFit().frame(width:60,height:60)
                }
                VStack(alignment:.leading) {
                    Text("ONCO REGISTER").font(.title2).bold()
                    Text(language.t("center")).font(.caption)
                }
            }
            Divider()
            Group {
                row("Ф.И.О.", patient.fullName)
                row("ПИНФЛ", patient.pinfl)
                row("Дата рождения", df.string(from:patient.birthDate))
                row("Адрес", patient.address)
                row("Дата диагноза", df.string(from:patient.diagnosisDate))
                row("МКБ-10", patient.icd10)
                row("ICD-O-3 Topography", patient.topography)
                row("Морфология", patient.morphologyText)
                row("ICD-O-3 Morphology", patient.morphologyCode)
                row("TNM", "\(patient.tStage) \(patient.nStage) \(patient.mStage)")
                row("Стадия", patient.stage)
                row("Лечение", language.enumLabel(patient.treatmentType.rawValue))
                row("Описание лечения", patient.treatmentDescription)
                row("Лечащий врач", patient.doctor)
            }
            Spacer()
            HStack { Text("Подпись врача: __________________________"); Spacer(); Text("Дата: _____________") }.font(.caption)
        }
        .padding(24)
        .frame(width:595,height:842,alignment:.topLeading)
    }
    @ViewBuilder func row(_ a:String,_ b:String)->some View {
        HStack(alignment:.top){ Text(a).bold().frame(width:150,alignment:.leading); Text(b); Spacer() }.font(.caption)
    }
}
