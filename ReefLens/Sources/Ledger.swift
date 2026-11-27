import SwiftUI
import PhotosUI
import AVFoundation
import WidgetKit

struct rRoot:View {
 @EnvironmentObject var z:rZ
 var body:some View{TabView(selection:$z.tab){NavigationStack{rHome()}.tabItem{Label(rL("identify"),systemImage:"viewfinder")}.tag(0);NavigationStack{rGuide()}.tabItem{Label(rL("guide"),systemImage:"fish")}.tag(1);NavigationStack{rFinds()}.tabItem{Label(rL("finds"),systemImage:"square.stack")}.tag(2);NavigationStack{rRules()}.tabItem{Label(rL("rules"),systemImage:"book.closed")}.tag(3)}.foregroundStyle(rDeep)}
}
struct rP:Identifiable {let id=UUID();var img:UIImage;var sample:Bool}
struct rHome:View {
 @EnvironmentObject var z:rZ
 @State private var item:PhotosPickerItem?;@State private var scan:rP?;@State private var camera=false;@State private var prefs=false;@State private var widgets=false
 func capture()async {guard UIImagePickerController.isSourceTypeAvailable(.camera) else{z.alert=rL("noCamera");return};let status=AVCaptureDevice.authorizationStatus(for:.video);let ok=status == .authorized ? true:(status == .notDetermined ? await AVCaptureDevice.requestAccess(for:.video):false);if ok && UIImagePickerController.isSourceTypeAvailable(.camera){camera=true}else{z.alert=rL("noCamera")}}
 var body:some View{
  ScrollView{VStack(alignment:.leading,spacing:24){
   HStack{HStack(spacing:10){Image(systemName:"viewfinder").font(.title2).foregroundStyle(rOrange);Text("Fish ID").font(.system(size:28,weight:.heavy,design:.rounded))};Spacer();Button{prefs=true}label:{Image(systemName:"slider.horizontal.3").padding(12).background(.white,in:Circle())}.accessibilityLabel(rL("settings")).accessibilityIdentifier("preferences")}
   ZStack(alignment:.topLeading){
    RoundedRectangle(cornerRadius:30).fill(LinearGradient(colors:[rDeep,rBlue],startPoint:.topLeading,endPoint:.bottomTrailing))
    GeometryReader{g in Circle().stroke(.white.opacity(0.07),lineWidth:1).frame(width:330).offset(x:g.size.width-220,y:20);Circle().stroke(.white.opacity(0.08),lineWidth:1).frame(width:220).offset(x:g.size.width-160,y:80)}.clipped()
    VStack(alignment:.leading,spacing:14){rLabel(text:"offline").foregroundStyle(rSand);Text(rL("hero")).font(.system(size:38,weight:.bold,design:.rounded)).tracking(-1.2).foregroundStyle(.white).fixedSize(horizontal:false,vertical:true);rFish(seed:"perch",bright:true).aspectRatio(1.9,contentMode:.fit).frame(maxWidth:345,maxHeight:176).frame(maxWidth:.infinity).padding(.horizontal,-8);HStack{Image(systemName:"circle.dotted");Text(rL("illustration")).font(.system(size:10,design:.monospaced));Spacer();Text("Perca fluviatilis").font(.system(size:10,design:.monospaced)).italic()}.foregroundStyle(rSand.opacity(0.85))}.padding(24)
   }.frame(minHeight:365)
   HStack(spacing:12){Button{Task{await capture()}}label:{Label(rL("camera"),systemImage:"camera.fill").foregroundStyle(rDeep).font(.headline).frame(maxWidth:.infinity,minHeight:54)}.buttonStyle(.borderedProminent).tint(rOrange).accessibilityIdentifier("openCamera");PhotosPicker(selection:$item,matching:.images,photoLibrary:.shared()){Label(rL("photo"),systemImage:"photo").font(.headline).frame(maxWidth:.infinity,minHeight:54)}.buttonStyle(.bordered).tint(rBlue).accessibilityIdentifier("choosePhoto")}
   rPanel{Label(rL("how"),systemImage:"viewfinder").font(.headline);Text(rL("howBody")).font(.subheadline).foregroundStyle(.secondary);Button{if let u=Bundle.main.url(forResource:"sample_rainbow",withExtension:"jpg"),let i=UIImage(contentsOfFile:u.path){scan=rP(img:i,sample:true)}}label:{HStack{Text(rL("sample"));Spacer();Image(systemName:"arrow.up.right")}}.accessibilityIdentifier("samplePhoto")}
   let f=rK.day()
   NavigationLink{rProfile(f:f)}label:{HStack(spacing:18){rFish(seed:f.id).frame(width:110,height:90).background(rSand.opacity(0.5),in:RoundedRectangle(cornerRadius:18));VStack(alignment:.leading,spacing:6){rLabel(text:"day").foregroundStyle(rBlue);Text(rL(f.name)).font(.headline);Text(f.latin).font(.caption).italic().foregroundStyle(.secondary)};Spacer();Image(systemName:"chevron.right")}.padding(16).background(.white,in:RoundedRectangle(cornerRadius:24))}.buttonStyle(.plain)
   Button{z.tab=1}label:{HStack{Text(rL("browse")).font(.headline);Spacer();Image(systemName:"arrow.right")}}.padding(.horizontal,8)
  }.padding(20).frame(maxWidth:900).frame(maxWidth:.infinity)}.background(rPaper).toolbar(.hidden,for:.navigationBar)
  .task {
   #if DEBUG
   if ProcessInfo.processInfo.arguments.contains("-RillWidgetPreview"){widgets=true}
   if ProcessInfo.processInfo.arguments.contains("-RillImportFixture"),let u=Bundle.main.url(forResource:"sample_rainbow",withExtension:"jpg"),let i=UIImage(contentsOfFile:u.path){scan=rP(img:i,sample:false)}
   #endif
  }
  .onChange(of:item){_,v in guard let v else{return};Task{do{guard let d=try await v.loadTransferable(type:Data.self),let i=rRead.decode(d) else{z.alert=rL("imageError");return};scan=rP(img:i,sample:false)}catch{z.alert=rL("imageError")};item=nil}}
  .sheet(isPresented:$camera){rCam{i in DispatchQueue.main.asyncAfter(deadline:.now()+0.5){scan=rP(img:i,sample:false)}}.ignoresSafeArea()}
  .sheet(item:$scan){rScan(img:$0.img,sample:$0.sample)}
  .sheet(isPresented:$widgets){
   #if DEBUG
   rWidgetGallery()
   #endif
  }
  .sheet(isPresented:$prefs){NavigationStack{rPrefs().toolbar{Button(rL("done")){prefs=false}}}}
 }
}
struct rGuide:View {
 @State private var search="";@State private var only=false;@EnvironmentObject var z:rZ
 var list:[rK]{rK.all.filter{(!only || z.data.favorites.contains($0.id)) && (search.isEmpty || rL($0.name).localizedCaseInsensitiveContains(search) || $0.latin.localizedCaseInsensitiveContains(search))}}
 var body:some View{ScrollView{VStack(alignment:.leading,spacing:20){HStack{Text(rL("browse")).font(.subheadline).foregroundStyle(.secondary);Spacer();Toggle(rL("favorites"),isOn:$only).toggleStyle(.button).font(.caption)};if list.isEmpty{ContentUnavailableView(rL(only ? "emptyFav":"noResults"),systemImage:only ? "heart":"magnifyingglass")}else{LazyVGrid(columns:[GridItem(.adaptive(minimum:155),spacing:16)],spacing:16){ForEach(list){f in NavigationLink{rProfile(f:f)}label:{VStack(alignment:.leading,spacing:8){rFish(seed:f.id).frame(height:110).background(rSand.opacity(0.45),in:RoundedRectangle(cornerRadius:18));Text(rL(f.name)).font(.headline).multilineTextAlignment(.leading);Text(f.latin).font(.caption2).italic().foregroundStyle(.secondary);HStack{Text(f.size).font(.caption.monospaced());Spacer();if z.data.favorites.contains(f.id){Image(systemName:"heart.fill").foregroundStyle(rOrange)}}}.padding(12).frame(maxWidth:.infinity,minHeight:214,alignment:.topLeading).background(.white,in:RoundedRectangle(cornerRadius:24))}.buttonStyle(.plain).accessibilityIdentifier("species-\(f.id)")}}}}.padding(20).frame(maxWidth:1100).frame(maxWidth:.infinity)}.background(rPaper).navigationTitle(rL("guide")).searchable(text:$search,prompt:rL("search"))}
}
struct rProfile:View {
 var f:rK;@EnvironmentObject var z:rZ
 var body:some View{ScrollView{VStack(alignment:.leading,spacing:22){ZStack{RoundedRectangle(cornerRadius:28).fill(rDeep);rFish(seed:f.id,bright:true).frame(height:230)};HStack(alignment:.top){VStack(alignment:.leading,spacing:7){Text(rL(f.name)).font(.largeTitle.bold());Text(f.latin).italic().foregroundStyle(.secondary)};Spacer();Button{z.star(f.id)}label:{Image(systemName:z.data.favorites.contains(f.id) ? "heart.fill":"heart").font(.title2).foregroundStyle(rOrange).padding(12)}.accessibilityLabel(rL("favorite")).accessibilityIdentifier("favorite")};rPanel{rLabel(text:"marks");Text(rL(f.marks)).font(.title3);NavigationLink { FieldComparison(original: f) } label: { Label(rL("compare"),systemImage:"rectangle.split.2x1") }.accessibilityIdentifier("compareSpecies")};HStack{Image(systemName:"ruler").font(.title2);VStack(alignment:.leading){Text(rL("size")).font(.caption);Text(f.size).font(.title2.bold())}}.padding(20).frame(maxWidth:.infinity,alignment:.leading).background(rSand,in:RoundedRectangle(cornerRadius:24));rPanel{rLabel(text:"habitat");Text(rL(f.habitat));if let range=f.nativeRange{Divider();rLabel(text:"nativeRange");Text(rL(range))}};rPanel{let isSeason = f.season != "reefLife" && f.season != "liveYoung";rLabel(text:isSeason ? "spawn" : "breeding");Text(rL(f.season)).font(.title2.bold());if isSeason{Text(rL("seasonNote")).font(.caption).foregroundStyle(.secondary)}};rPanel{rLabel(text:"recognitionScope");Label(rL(f.photoSupported ? "recognisedTag" : "guideTag"),systemImage:f.photoSupported ? "viewfinder" : "book")};NavigationLink(rL("rules")){rRules()}.buttonStyle(.bordered);Text(rL("illustration")+" • Fish ID").font(.caption).foregroundStyle(.secondary)}.padding(20).frame(maxWidth:800).frame(maxWidth:.infinity)}.background(rPaper).navigationTitle(rL(f.name)).navigationBarTitleDisplayMode(.inline).toolbar(.visible,for:.navigationBar)}
}
struct rFinds:View {
 @EnvironmentObject var z:rZ
 var body:some View{ScrollView{VStack(alignment:.leading,spacing:20){HStack(spacing:16){rPanel{Text("\(z.weekly)").font(.system(size:38,weight:.bold,design:.rounded)).foregroundStyle(rBlue);Text(rL("week")).font(.caption)};rPanel{Text("\(Set(z.data.finds.map{$0.latin}).count)").font(.system(size:38,weight:.bold,design:.rounded)).foregroundStyle(rOrange);Text(rL("collection")).font(.caption)}};rPanel{HStack{Image(systemName:"leaf").foregroundStyle(rBlue);Text(rL("challenge")).font(.headline);Spacer();Text("\(min(z.seasonal,3))/3").monospacedDigit()};ProgressView(value:Double(min(z.seasonal,3)),total:3).tint(rOrange);Text(rL("challengeBody")).font(.caption).foregroundStyle(.secondary)};if z.data.finds.isEmpty{ContentUnavailableView{Label(rL("empty"),systemImage:"fish")}description:{Text(rL("emptyBody"))}actions:{Button { z.tab=0 } label: { Text(rL("identify")).foregroundStyle(.white) }.buttonStyle(.borderedProminent).tint(rBlue)}}else{ForEach(z.data.finds){f in NavigationLink{rFindDetail(find:f)}label:{HStack{if let i=z.photo(f){Image(uiImage:i).resizable().scaledToFill().frame(width:86,height:86).clipped().clipShape(RoundedRectangle(cornerRadius:16))}else if let species=rK.find(f.latin){rFish(seed:species.id).frame(width:86,height:86).background(rSand,in:RoundedRectangle(cornerRadius:16))};VStack(alignment:.leading,spacing:8){Text(rK.find(f.latin).map{rL($0.name)} ?? f.latin).font(.headline);Text(f.date.formatted(date:.abbreviated,time:.shortened)).font(.caption).foregroundStyle(.secondary);Text(f.note).font(.caption).lineLimit(1)};Spacer();Image(systemName:"chevron.right")}.padding(12).background(.white,in:RoundedRectangle(cornerRadius:22))}.buttonStyle(.plain).accessibilityIdentifier("findRow")}}}.padding(20).frame(maxWidth:900).frame(maxWidth:.infinity)}.background(rPaper).navigationTitle(rL("finds"))}
}
struct rFindDetail:View {
 var find:rF;@EnvironmentObject var z:rZ;@Environment(\.dismiss)var dismiss;@State private var note="";@State private var ask=false
 var body:some View{ScrollView{VStack(alignment:.leading,spacing:20){if let i=z.photo(find){Image(uiImage:i).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius:24))};Text(find.latin).font(.title2.italic());Text(find.date.formatted(date:.long,time:.shortened)).font(.caption);TextField(rL("notes"),text:$note,axis:.vertical).lineLimit(3...8).padding().background(.white,in:RoundedRectangle(cornerRadius:18));Button(rL("saveNote")){z.note(find,note)}.buttonStyle(.bordered);if let f=rK.find(find.latin){NavigationLink(rL(f.name)){rProfile(f:f)}};Button{Task{var f=find;f.note=note;await z.export(f)}}label:{Label(rL("export"),systemImage:"square.and.arrow.down").foregroundStyle(.white)}.buttonStyle(.borderedProminent);Button(rL("delete"),role:.destructive){ask=true}.accessibilityIdentifier("deleteFind")}.padding(20).frame(maxWidth:800).frame(maxWidth:.infinity)}.background(rPaper).navigationTitle(rL("finds")).navigationBarTitleDisplayMode(.inline).toolbar(.visible,for:.navigationBar).onAppear{note=z.data.finds.first{$0.id==find.id}?.note ?? find.note}.confirmationDialog(rL("deleteAsk"),isPresented:$ask,titleVisibility:.visible){Button(rL("delete"),role:.destructive){z.remove(find);dismiss()}}}
}
struct rRules:View {
 var body:some View{ScrollView{VStack(alignment:.leading,spacing:20){rLabel(text:"region").foregroundStyle(rBlue);Text(rL("coverage")).font(.title2.bold());Label(rL("verified"),systemImage:"checkmark.seal").font(.caption).foregroundStyle(.secondary);Text(rL("ruleWarning")).font(.subheadline).padding(20).background(rSand,in:RoundedRectangle(cornerRadius:22));ForEach(Array(["bassRule","eelRule","peacockRule","protectedRule","seasonRule"].enumerated()),id:\.offset){n,k in rPanel{HStack(alignment:.top,spacing:14){Text(String(format:"%02d",n+1)).font(.system(.title3,design:.monospaced)).foregroundStyle(rBlue);Text(rL(k)).frame(maxWidth:.infinity,alignment:.leading)}}};rPanel{rLabel(text:"source");Link("Florida Fish and Wildlife Conservation Commission ↗",destination:URL(string:"https://myfwc.com/fishing/freshwater/regulations/general/")!);Link("Florida Wildlife Code · 68A-23.005 ↗",destination:URL(string:"https://flrules.org/gateway/ChapterHome.asp?Chapter=68A-23")!);Text(rL("noRegion")).font(.caption).foregroundStyle(.secondary)}}.padding(20).frame(maxWidth:800).frame(maxWidth:.infinity)}.background(rPaper).navigationTitle(rL("rules"))}
}
struct rPrefs:View {
 @EnvironmentObject var z:rZ
 var body:some View{ScrollView{VStack(alignment:.leading,spacing:22){rPanel{Label(rL("reminders"),systemImage:"bell").font(.title3.bold());if let e=z.alert{Text(e).font(.footnote).foregroundStyle(rDeep)};Text(rL("reminderValue")).font(.subheadline);Button { if z.data.reminds { z.off() } else { Task { await z.notify() } } } label: { Text(rL(z.data.reminds ? "disable":"enable")).foregroundStyle(.white) }.buttonStyle(.borderedProminent).tint(rBlue);Button(rL("openSettings")){if let u=URL(string:UIApplication.openSettingsURLString){UIApplication.shared.open(u)}}.font(.caption)};rPanel{rLabel(text:"privacy");Text(rL("privacyBody"));Divider();Text(rL("modelBody")).font(.subheadline);Text(rL("license")).font(.caption);Link("iNaturalist ↗",destination:URL(string:"https://github.com/inaturalist/model-files/releases/tag/v25.01.15")!);Link(rL("sourcePhoto")+" · USFWS ↗",destination:URL(string:"https://www.fws.gov/media/rainbow-trout-4")!)};Text("Fish ID · 1.3.0 (2037)").font(.caption.monospaced()).foregroundStyle(.secondary)}.padding(20).frame(maxWidth:800).frame(maxWidth:.infinity)}.background(rPaper).navigationTitle(rL("settings"))}
}

#if DEBUG
struct rWidgetGallery:View {
 var body:some View{ScrollView{VStack(spacing:20){Text("Widget rendering QA").font(.headline);rWidgetFace(entry:rEntry(date:.now,state:rS.read()),forced:.systemSmall).frame(width:164,height:164).padding(16).background(rDeep,in:RoundedRectangle(cornerRadius:25));rWidgetFace(entry:rEntry(date:.now,state:rS.read()),forced:.systemMedium).frame(width:320,height:140).padding(16).background(rPaper,in:RoundedRectangle(cornerRadius:25));rWidgetFace(entry:rEntry(date:.now,state:rS.read()),forced:.systemLarge).frame(width:320,height:310).padding(16).background(rPaper,in:RoundedRectangle(cornerRadius:25));rWidgetFace(entry:rEntry(date:.now,state:rS.read()),forced:.accessoryRectangular).frame(width:172,height:64).padding(16).background(.gray.opacity(0.1),in:RoundedRectangle(cornerRadius:20))}.padding(20)}.background(.white)}
}
#endif


struct FieldComparison: View {
  let original: rK
  @State private var comparisonID: String

  init(original: rK) {
    self.original = original
    let pairs = ["bass":"largemouth","largemouth":"bass","smallmouth":"largemouth","western":"eastern","eastern":"western","redbreast":"bluegill","green":"pumpkin","pumpkin":"green","yellow":"perch","channel":"carp","creek":"western","rainbow":"brown","brown":"brook","brook":"rainbow","perch":"walleye","walleye":"perch","tench":"carp","carp":"tench","crappie":"bluegill","bluegill":"crappie","pike":"walleye"]
    _comparisonID = State(initialValue: pairs[original.id] ?? "bass")
  }

  var body: some View {
    ScrollView {
      VStack(alignment:.leading, spacing:18) {
        Picker(rL("compareWith"), selection:$comparisonID) {
          ForEach(rK.all.filter { $0.id != original.id }) { fish in
            Text(rL(fish.name)).tag(fish.id)
          }
        }.pickerStyle(.menu)
        if let comparison = rK.all.first(where: { $0.id == comparisonID }) {
          ViewThatFits(in:.horizontal) {
            HStack(alignment:.top) { specimen(original).frame(width:285); specimen(comparison).frame(width:285) }
            VStack(spacing:14) { specimen(original); specimen(comparison) }
          }
        }
      }.padding(20).frame(maxWidth:850).frame(maxWidth:.infinity)
    }.background(rPaper).navigationTitle(rL("compare")).navigationBarTitleDisplayMode(.inline)
  }

  private func specimen(_ fish: rK) -> some View {
    rPanel {
      rFish(seed:fish.id).aspectRatio(2.2,contentMode:.fit).frame(maxWidth:.infinity).background(rSand.opacity(0.4),in:RoundedRectangle(cornerRadius:16))
      Text(rL(fish.name)).font(.title3.bold())
      Text(fish.latin).font(.caption).italic()
      Divider()
      Text(rL(fish.marks)).font(.body)
      Label(fish.size,systemImage:"ruler").font(.callout.weight(.semibold))
      Text(rL(fish.habitat)).font(.footnote).foregroundStyle(.secondary)
    }
  }
}

#if DEBUG
struct FieldCapture: View {
  let index: Int
  @EnvironmentObject var store: rZ

  static var index: Int? {
    let process = ProcessInfo.processInfo
    let args = process.arguments
    guard args.contains("-AppStoreScreenshots") || process.environment["APPSTORE_SCREENSHOTS"] == "1" else { return nil }
    let value = args.firstIndex(of:"-AppStoreScreenshotScreen").flatMap { args.indices.contains($0 + 1) ? Int(args[$0 + 1]) : nil }
    let index = value ?? Int(process.environment["APPSTORE_SCREENSHOT_SCREEN"] ?? "") ?? 0
    return (0..<6).contains(index) ? index : nil
  }
  static var sample: UIImage? {
    Bundle.main.url(forResource:"sample_rainbow",withExtension:"jpg").flatMap { UIImage(contentsOfFile:$0.path) }
  }

  var body: some View {
    ZStack {
      rPaper.ignoresSafeArea()
      switch index {
      case 1:
        if let sample = Self.sample { rScan(img:sample,sample:true) }
      case 2: NavigationStack { rGuide().navigationBarTitleDisplayMode(.inline) }
      case 3: if let fish = rK.all.first(where: { $0.id == "largemouth" }) { NavigationStack { rProfile(f:fish) } }
      case 4: NavigationStack { rFinds().navigationBarTitleDisplayMode(.inline) }
      case 5: if let find = store.data.finds.first { NavigationStack { rFindDetail(find:find) } }
      default: rRoot()
      }
    }
    .foregroundStyle(rDeep)
    .onAppear {
      guard index == 4 || index == 5 else { return }
      let names = ["Oncorhynchus mykiss","Perca fluviatilis","Esox lucius","Micropterus nigricans","Lepomis macrochirus"]
      let dates = names.indices.map { Date.now.addingTimeInterval(-Double($0)*86400) }
      store.data.finds = names.enumerated().map { row,name in
        rF(id: UUID(), latin:name, date:dates[row], photo:row == 0 ? "field-sample" : "", note:rL(["demoNote","bars","long","band","ear"][row]))
      }
      store.data.scans = dates
    }
  }
}
#endif
