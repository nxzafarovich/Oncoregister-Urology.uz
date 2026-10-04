import SwiftUI

struct PatientFormView: View {
    @EnvironmentObject var language: LanguageStore
    @EnvironmentObject var db: DatabaseManager
    @Environment(\.dismiss) private var dismiss

    @State var patient: Patient
    @State private var selectedMorphology = ""
    @State private var selectedDoctor = ""
    @State private var errorText = ""
    @State private var showError = false

    init(patient: Patient = Patient()) {
        _patient = State(initialValue: patient)
        _selectedMorphology = State(initialValue: patient.morphologyCode)
        _selectedDoctor = State(initialValue: patient.doctor)
    }

    var body: some View {
        ScrollView {
            VStack(alignment:.leading, spacing:18) {
                section("1. Паспортная часть") {
                    grid {
                        TextField("Фамилия *", text:$patient.surname)
                        TextField("Имя *", text:$patient.name)
                        TextField("Отчество", text:$patient.patronymic)
                        TextField("ПИНФЛ / JShShIR *", text:$patient.pinfl)
                        Picker("Пол", selection:$patient.sex) { ForEach(Sex.allCases,id:\.self){ Text(language.enumLabel($0.rawValue)).tag($0) } }
                        DatePicker("Дата рождения", selection:$patient.birthDate, displayedComponents:.date)
                        TextField("Гражданство", text:$patient.citizenship)
                        Picker("Лечащий врач", selection:$selectedDoctor) {
                            Text("").tag("")
                            ForEach(Catalog.doctors,id:\.self){ Text($0).tag($0) }
                            Text("Другой / вручную").tag("__other__")
                        }.onChange(of:selectedDoctor){ v in if v != "__other__" { patient.doctor = v } }
                        if selectedDoctor == "__other__" { TextField("Ф.И.О. врача", text:$patient.doctor) }
                    }
                    TextField("Адрес *", text:$patient.address)
                }
                section("2. Диагноз") {
                    grid {
                        DatePicker("Дата диагноза *", selection:$patient.diagnosisDate, displayedComponents:.date)
                        Picker("Локализация *", selection:$patient.tumorSiteID) {
                            Text("").tag("")
                            ForEach(Catalog.tumorSites){ Text(language.siteName($0)).tag($0.id) }
                        }.onChange(of:patient.tumorSiteID){ id in
                            if let s=Catalog.tumorSites.first(where:{$0.id==id}) {
                                patient.icd10=s.icd10; patient.topography=s.topography
                            }
                        }
                        TextField("МКБ-10 *", text:$patient.icd10)
                        TextField("ICD-O-3 Topography", text:$patient.topography)
                        Picker("Морфология / гистология", selection:$selectedMorphology) {
                            Text("").tag("")
                            ForEach(Catalog.morphologies){ Text("\($0.code) — \(language.morphologyName($0))").tag($0.id) }
                        }.onChange(of:selectedMorphology){ id in
                            if let m=Catalog.morphologies.first(where:{$0.id==id}) {
                                patient.morphologyCode=m.code
                                if id != "other" { patient.morphologyText=language.morphologyName(m) }
                            }
                        }
                        TextField("ICD-O-3 Morphology", text:$patient.morphologyCode)
                        TextField("Морфология (текст)", text:$patient.morphologyText)
                        Picker("Метод подтверждения",selection:$patient.verification){ ForEach(VerificationMethod.allCases,id:\.self){Text(language.enumLabel($0.rawValue)).tag($0)}}
                        Picker("Биологическое поведение",selection:$patient.biologicalBehavior){ForEach(BiologicalBehavior.allCases,id:\.self){Text(language.enumLabel($0.rawValue)).tag($0)}}
                        TextField("Дифференцировка (G)",text:$patient.grade)
                        Picker("T",selection:$patient.tStage){ForEach(Catalog.tStages,id:\.self){Text($0).tag($0)}}
                        Picker("N",selection:$patient.nStage){ForEach(Catalog.nStages,id:\.self){Text($0).tag($0)}}
                        Picker("M",selection:$patient.mStage){ForEach(Catalog.mStages,id:\.self){Text($0).tag($0)}}
                        Picker("Стадия",selection:$patient.stage){ForEach(Catalog.stages,id:\.self){Text($0).tag($0)}}
                    }
                }
                section("3. Лечение в Центре урологии") {
                    Text("В этой версии: хирургическое лечение, внутрипузырные инстилляции и гормональная терапия.").font(.caption).foregroundStyle(.secondary)
                    grid {
                        optionalDate("Дата начала", date:$patient.treatmentStart)
                        optionalDate("Дата окончания", date:$patient.treatmentEnd)
                        Picker("Вид лечения",selection:$patient.treatmentType){ForEach(TreatmentType.allCases,id:\.self){Text(language.enumLabel($0.rawValue)).tag($0)}}
                        optionalDate("Дата воздействия / операции", date:$patient.treatmentDate)
                    }
                    if patient.treatmentType == .surgery {
                        Picker("Операция",selection:$patient.operationID){
                            Text("").tag("")
                            ForEach(Catalog.operations){Text(language.operationName($0)).tag($0.id)}
                        }
                        .onChange(of:patient.operationID){ id in
                            if let o=Catalog.operations.first(where:{$0.id==id}) { patient.treatmentDescription=language.operationDescription(o) }
                        }
                    } else if patient.treatmentType == .intravesical {
                        Picker("Внутрипузырная инстилляция",selection:$patient.instillation){
                            Text("").tag("")
                            ForEach(Catalog.instillations,id:\.self){Text($0).tag($0)}
                        }
                    }
                    TextEditor(text:$patient.treatmentDescription).frame(minHeight:90).overlay(RoundedRectangle(cornerRadius:6).stroke(.quaternary))
                }
                section("4. Последнее наблюдение") {
                    grid {
                        optionalDate("Последний контакт", date:$patient.lastContact)
                        Picker("Состояние",selection:$patient.contactStatus){ForEach(ContactStatus.allCases,id:\.self){Text(language.enumLabel($0.rawValue)).tag($0)}}
                        Picker("Статус заболевания",selection:$patient.diseaseStatus){ForEach(DiseaseStatus.allCases,id:\.self){Text(language.enumLabel($0.rawValue)).tag($0)}}
                        if patient.contactStatus == .deceased {
                            optionalDate("Дата смерти",date:$patient.deathDate)
                            TextField("Причина смерти",text:$patient.deathCause)
                        }
                    }
                }
                HStack {
                    Spacer()
                    Button(language.t("cancel")){ dismiss() }
                    Button(language.t("savePrint")){ save(print:true) }.buttonStyle(.bordered)
                    Button(language.t("save")){ save(print:false) }.buttonStyle(.borderedProminent)
                }
            }.padding(22)
        }
        .alert("Onco Register", isPresented:$showError){ Button("OK",role:.cancel){} } message:{ Text(errorText) }
        .onAppear { if !patient.doctor.isEmpty { selectedDoctor=patient.doctor } }
    }

    func save(print:Bool) {
        guard !patient.surname.isEmpty, !patient.name.isEmpty, !patient.pinfl.isEmpty, !patient.tumorSiteID.isEmpty else {
            errorText="Заполните обязательные поля."; showError=true; return
        }
        do {
            try db.save(patient)
            if print { PrintHelper.printPatient(patient, language:language) }
            dismiss()
        } catch { errorText=error.localizedDescription; showError=true }
    }

    @ViewBuilder func section<Content:View>(_ title:String,@ViewBuilder content:()->Content)->some View {
        VStack(alignment:.leading,spacing:12){
            Text(title).font(.headline).foregroundStyle(Color(red:0.08,green:0.22,blue:0.32))
            content()
        }.padding().background(Color(nsColor:.controlBackgroundColor)).clipShape(RoundedRectangle(cornerRadius:12))
    }
    @ViewBuilder func grid<Content:View>(@ViewBuilder content:()->Content)->some View {
        LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())],spacing:12){content()}
    }
    @ViewBuilder func optionalDate(_ title:String,date:Binding<Date?>)->some View {
        ToggleDateField(title:title,date:date)
    }
}

struct ToggleDateField: View {
    let title:String
    @Binding var date: Date?
    @State private var enabled=false
    var body:some View{
        HStack{
            Toggle("",isOn:$enabled).labelsHidden().onChange(of:enabled){ if !$0 { date=nil } else if date==nil { date=Date() } }
            if enabled { DatePicker(title,selection:Binding(get:{date ?? Date()},set:{date=$0}),displayedComponents:.date) }
            else { Text(title).foregroundStyle(.secondary); Spacer() }
        }.onAppear{enabled=date != nil}
    }
}
