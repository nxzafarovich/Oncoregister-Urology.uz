import SwiftUI

struct ExportView: View {
    @EnvironmentObject var language: LanguageStore
    @EnvironmentObject var db: DatabaseManager
    @State private var year=Calendar.current.component(.year,from:Date())
    @State private var month=Calendar.current.component(.month,from:Date())
    var body:some View{
        VStack(spacing:18){
            Text(language.t("export")).font(.title2).bold()
            HStack{
                Picker("Год",selection:$year){ForEach((2020...2035).reversed(),id:\.self){Text(String($0)).tag($0)}}
                Picker("Месяц",selection:$month){ForEach(1...12,id:\.self){Text(String(format:"%02d",$0)).tag($0)}}
            }.frame(width:420)
            Button(language.t("export")){
                do{
                    let u=try db.exportSpreadsheetML(year:year,month:month,language:language)
                    NSAlert.informative("Excel сохранён:\n\(u.path)")
                }catch{NSAlert(error:error).runModal()}
            }.buttonStyle(.borderedProminent)
            Button("Главная"){NotificationCenter.default.post(name:.init("GoHome"),object:nil)}
            Spacer()
        }.padding(30)
    }
}
