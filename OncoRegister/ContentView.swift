import SwiftUI
import AppKit

enum MainRoute { case home, list, export }

struct ContentView: View {
    @EnvironmentObject var language: LanguageStore
    @EnvironmentObject var db: DatabaseManager
    @State private var route: MainRoute = .home
    @State private var search = ""
    @State private var showingNew = false
    @State private var editing: Patient?
    @State private var message = ""

    var body: some View {
        VStack(spacing:0) {
            header
            Group {
                switch route {
                case .home: home
                case .list: PatientListView(editing:$editing)
                case .export: ExportView()
                }
            }
        }
        .sheet(isPresented:$showingNew){ PatientFormView().environmentObject(language).environmentObject(db).frame(minWidth:980,minHeight:700) }
        .sheet(item:$editing){ p in PatientFormView(patient:p).environmentObject(language).environmentObject(db).frame(minWidth:980,minHeight:700) }
        .onReceive(NotificationCenter.default.publisher(for:.init("GoHome"))){ _ in route = .home }
    }

    var header: some View {
        HStack(spacing:16) {
            HStack(spacing:14) {
                if let u=Bundle.main.url(forResource:"rscu-logo_light2",withExtension:"png"),
                   let img=NSImage(contentsOf:u) {
                    Image(nsImage:img).resizable().scaledToFit().frame(width:68,height:68)
                }
                VStack(alignment:.leading,spacing:4){
                    Text("ONCO REGISTER").font(.title).bold()
                    Text(language.t("center")).font(.subheadline)
                }
            }
            .contentShape(Rectangle()).onTapGesture { route = .home }
            Spacer()
            Picker("",selection:$language.language){
                Text("RU").tag(AppLanguage.ru);Text("UZ").tag(AppLanguage.uz);Text("EN").tag(AppLanguage.en)
            }.pickerStyle(.segmented).frame(width:180)
        }
        .padding(.horizontal,24).padding(.vertical,14)
        .foregroundStyle(.white)
        .background(Color(red:0.07,green:0.20,blue:0.29))
    }

    var home: some View {
        ScrollView {
            VStack(spacing:18) {
                HStack {
                    TextField(language.t("search"),text:$search).textFieldStyle(.roundedBorder)
                    Button("Найти"){ findPatient() }.buttonStyle(.borderedProminent)
                }
                HStack {
                    Text(language.t("sharedDB")+":").bold()
                    Text(db.databasePath).font(.caption).textSelection(.enabled)
                    Spacer()
                    Button("Обновить"){ try? db.reload() }
                }
                .padding(10).background(Color.green.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius:9))

                LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())],spacing:16){
                    action("person.badge.plus",language.t("newPatient")){showingNew=true}
                    action("person.3",language.t("patients")){route = .list; try? db.reload()}
                    action("square.and.arrow.down",language.t("export")){route = .export}
                    action("externaldrive.badge.timemachine",language.t("backup")){createBackup()}
                }
                Spacer(minLength:30)
                VStack(spacing:4){
                    Text("\(language.t("creatorLabel")): \(language.t("creator"))")
                    Text("E-mail: nxzafarovich@gmail.com")
                }.font(.caption).foregroundStyle(.secondary)
            }.padding(24)
        }
    }

    func action(_ icon:String,_ title:String,action:@escaping()->Void)->some View {
        Button(action:action){
            HStack(spacing:14){Image(systemName:icon).font(.title2);Text(title).font(.title3).bold();Spacer()}
                .padding(24).frame(maxWidth:.infinity,minHeight:100)
        }.buttonStyle(.plain).background(Color(nsColor:.controlBackgroundColor)).clipShape(RoundedRectangle(cornerRadius:14))
            .overlay(RoundedRectangle(cornerRadius:14).stroke(.quaternary))
    }

    func findPatient(){
        try? db.reload()
        let q=search.lowercased()
        if let p=db.patients.first(where:{$0.pinfl.lowercased().contains(q)||$0.fullName.lowercased().contains(q)}) { editing=p }
        else { NSAlert.informative("Пациент не найден.") }
    }
    func createBackup(){
        do { let u=try db.createBackup(); NSAlert.informative("Резервная копия создана:\n\(u.path)") }
        catch { NSAlert(error:error).runModal() }
    }
}

extension NSAlert {
    static func informative(_ text:String){
        let a=NSAlert();a.messageText="Onco Register";a.informativeText=text;a.runModal()
    }
}
