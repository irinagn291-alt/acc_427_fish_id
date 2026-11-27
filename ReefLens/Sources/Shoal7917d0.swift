import SwiftUI
import UserNotifications
import Photos
import WidgetKit

@MainActor final class rZ:ObservableObject {
 @Published var data=rD();@Published var alert:String?;@Published var tab=0;@Published var shown:rK?
 let folder:URL
 init(){folder=FileManager.default.urls(for:.applicationSupportDirectory,in:.userDomainMask)[0].appendingPathComponent("RillField",isDirectory:true);do{try FileManager.default.createDirectory(at:folder,withIntermediateDirectories:true);let u=folder.appendingPathComponent("field.json");if FileManager.default.fileExists(atPath:u.path){data=try JSONDecoder().decode(rD.self,from:Data(contentsOf:u))};sync()}catch{alert=rL("diskError")}}
 func persist(_ next:rD)throws {let bytes=try JSONEncoder().encode(next);try bytes.write(to:folder.appendingPathComponent("field.json"),options:[.atomic,.completeFileProtectionUntilFirstUserAuthentication]);data=next;sync()}
 func sync(){let s=rS(dates:data.scans,favorites:data.favorites,recent:Array(data.finds.prefix(3).map{$0.latin}),count:data.finds.count);if let u=rS.url,let d=try? JSONEncoder().encode(s){try? d.write(to:u,options:.atomic)};WidgetCenter.shared.reloadAllTimelines()}
 func scan(){var d=data;d.scans.append(.now);do{try persist(d)}catch{alert=rL("diskError")}}
 func star(_ id:String){var d=data;if d.favorites.contains(id){d.favorites.removeAll{$0==id}}else{d.favorites.append(id)};do{try persist(d)}catch{alert=rL("diskError")}}
 func save(_ image:UIImage,latin:String,note:String)->Bool {let id=UUID(),name=id.uuidString+".jpg";do{guard let b=image.jpegData(compressionQuality:0.86) else{throw CocoaError(.fileWriteUnknown)};try b.write(to:folder.appendingPathComponent(name),options:[.atomic,.completeFileProtection]);var d=data;d.finds.insert(rF(id:id,latin:latin,date:.now,photo:name,note:note),at:0);do{try persist(d)}catch{try? FileManager.default.removeItem(at:folder.appendingPathComponent(name));throw error};return true}catch{alert=rL("diskError");return false}}
 func photo(_ f:rF)->UIImage? {
  #if DEBUG
  if FieldCapture.index != nil, f.photo == "field-sample" {return FieldCapture.sample}
  #endif
  guard !f.photo.isEmpty else { return nil }
  return UIImage(contentsOfFile:folder.appendingPathComponent(f.photo).path)
 }
 func remove(_ f:rF){var d=data;d.finds.removeAll{$0.id==f.id};do{try persist(d);try? FileManager.default.removeItem(at:folder.appendingPathComponent(f.photo))}catch{alert=rL("diskError")}}
 func note(_ f:rF,_ n:String){var d=data;if let i=d.finds.firstIndex(where:{$0.id==f.id}){d.finds[i].note=n};do{try persist(d)}catch{alert=rL("diskError")}}
 var weekly:Int {rS(dates:data.scans).weekly}
 var seasonal:Int {let c=Calendar.current;let m=c.component(.month,from:.now);let season=(m % 12)/3;let year=c.component(.year,from:.now);return Set(data.finds.filter{let fm=c.component(.month,from:$0.date);let fy=c.component(.year,from:$0.date);return fm%12/3==season && (fm==12 ? fy+1:fy)==(m==12 ? year+1:year)}.map{$0.latin}).count}
 func notify()async {let n=UNUserNotificationCenter.current();do{let ok=try await n.requestAuthorization(options:[.alert,.sound,.badge]);guard ok else {alert=rL("notifyDenied");return};n.removeAllPendingNotificationRequests();let content=UNMutableNotificationContent();content.title=rL("day");content.body=rL("dailyBody");content.sound = .default;try await n.add(UNNotificationRequest(identifier:"species-daily",content:content,trigger:UNCalendarNotificationTrigger(dateMatching:DateComponents(hour:9,minute:0),repeats:true)));for m in [3,6,9,12] {let content=UNMutableNotificationContent();content.title=rL("challenge");content.body=rL("challengeBody");content.sound = .default;try await n.add(UNNotificationRequest(identifier:"season-\(m)",content:content,trigger:UNCalendarNotificationTrigger(dateMatching:DateComponents(month:m,day:1,hour:9),repeats:true)))};var d=data;d.reminds=true;try persist(d)}catch{alert=error.localizedDescription}}
 func off(){UNUserNotificationCenter.current().removeAllPendingNotificationRequests();var d=data;d.reminds=false;do{try persist(d)}catch{alert=rL("diskError")}}
 func export(_ f:rF)async {guard let image=photo(f) else{return};let title=rK.find(f.latin).map{rL($0.name)} ?? f.latin;let view=VStack(alignment:.leading,spacing:20){Text("Fish ID").font(.title.bold());Image(uiImage:image).resizable().scaledToFit().frame(width:900,height:650).clipped();Text(title).font(.largeTitle.bold());Text(f.latin).italic();Text(f.date.formatted(date:.long,time:.omitted));Text(f.note)}.padding(40).frame(width:980).foregroundStyle(rDeep).background(rPaper);let renderer=ImageRenderer(content:view);guard let card=renderer.uiImage else{return};let status=await PHPhotoLibrary.requestAuthorization(for:.addOnly);guard status == .authorized || status == .limited else{alert=rL("photoDenied");return};do{try await PHPhotoLibrary.shared().performChanges{PHAssetChangeRequest.creationRequestForAsset(from:card)};alert=rL("exported")}catch{alert=error.localizedDescription}}
}
@main struct rApp:App {
 @StateObject private var z=rZ()
 @ViewBuilder private var launchView: some View {
   #if DEBUG
   if let index = FieldCapture.index {
     FieldCapture(index: index)
   } else {
     rRoot()
   }
   #else
   rRoot()
   #endif
 }
 var body:some Scene{WindowGroup{launchView.environmentObject(z).tint(rBlue).preferredColorScheme(.light).onOpenURL{u in if u.host=="species",let f=rK.all.first(where:{$0.id==u.lastPathComponent}){z.tab=1;z.shown=f}else if u.host=="finds"{z.tab=2}else if u.host=="guide"{z.tab=1}else{z.tab=0}}.sheet(item:$z.shown){f in NavigationStack{rProfile(f:f).toolbar{Button(rL("done")){z.shown=nil}}}.environmentObject(z)}.alert("Fish ID",isPresented:Binding(get:{z.alert != nil},set:{if !$0{z.alert=nil}})){Button(rL("ok")){z.alert=nil}}message:{Text(z.alert ?? "")}}}
}
