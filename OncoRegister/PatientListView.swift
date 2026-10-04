import SwiftUI

struct PatientListView: View {
    @EnvironmentObject var language: LanguageStore
    @EnvironmentObject var db: DatabaseManager
    @Binding var editing: Patient?
    @State private var query=""
    @State private var year=0
    @State private var month=0

    var filtered:[Patient] {
        let cal=Calendar.current
        return db.patients.filter { p in
            let qok=query.isEmpty || p.fullName.localizedCaseInsensitiveContains(query) || p.pinfl.contains(query)
            let yok=year==0 || cal.component(.year,from:p.diagnosisDate)==year
            let mok=month==0 || cal.component(.month,from:p.diagnosisDate)==month
            return qok && yok && mok
        }
    }
    var years:[Int] {
        Array(Set(db.patients.map{Calendar.current.component(.year,from:$0.diagnosisDate)})).sorted(by:>)
    }
    var body:some View{
        VStack(spacing:12){
            HStack{
                TextField(language.t("search"),text:$query).textFieldStyle(.roundedBorder)
                Picker("Год",selection:$year){Text("Все годы").tag(0);ForEach(years,id:\.self){Text(String($0)).tag($0)}}
                Picker("Месяц",selection:$month){Text("Все месяцы").tag(0);ForEach(1...12,id:\.self){Text(String(format:"%02d",$0)).tag($0)}}
                Button("Главная"){NotificationCenter.default.post(name:.init("GoHome"),object:nil)}
                Button("Обновить"){try? db.reload()}
            }
            Table(filtered){
                TableColumn("Ф.И.О."){$0.fullNameText}
                TableColumn("ПИНФЛ"){$0.pinflText}
                TableColumn("МКБ-10"){$0.icdText}
                TableColumn("TNM"){$0.tnmText}
                TableColumn("Стадия"){$0.stageText}
                TableColumn("Дата диагноза"){$0.diagDateText}
            }
            .onTapGesture(count:2){ /* Selection is handled via row context below in v1 */ }
            HStack{
                Text("Всего: \(filtered.count)").foregroundStyle(.secondary)
                Spacer()
                Picker("Открыть пациента",selection:Binding(
                    get:{UUID?.none},
                    set:{id in if let id,let p=filtered.first(where:{$0.id==id}){editing=p}}
                )){
                    Text("Выберите пациента…").tag(UUID?.none)
                    ForEach(filtered){p in Text(p.fullName+" — "+p.pinfl).tag(Optional(p.id))}
                }.frame(width:420)
            }
        }.padding(20).onAppear{try? db.reload()}
    }
}

private extension Patient {
    var fullNameText:Text{Text(fullName)}
    var pinflText:Text{Text(pinfl)}
    var icdText:Text{Text(icd10)}
    var tnmText:Text{Text("\(tStage) \(nStage) \(mStage)")}
    var stageText:Text{Text(stage)}
    var diagDateText:Text{let f=DateFormatter();f.dateFormat="dd.MM.yyyy";return Text(f.string(from:diagnosisDate))}
}
