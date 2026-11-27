import SwiftUI
import CoreML
import Vision
import ImageIO

enum rRead {
 static func decode(_ data:Data)->UIImage? {guard let source=CGImageSourceCreateWithData(data as CFData,nil),let cg=CGImageSourceCreateThumbnailAtIndex(source,0,[kCGImageSourceCreateThumbnailFromImageAlways:true,kCGImageSourceThumbnailMaxPixelSize:2048,kCGImageSourceCreateThumbnailWithTransform:true] as CFDictionary) else{return nil};return UIImage(cgImage:cg)}
 private static let classifier = Result {
  guard let modelURL = Bundle.main.url(forResource: FishClassifier.modelName, withExtension: "mlmodelc"),
        let classesURL = Bundle.main.url(forResource: "FishClasses", withExtension: "json") else {
   throw CocoaError(.fileNoSuchFile)
  }
  return try FishClassifier(modelURL: modelURL, classesURL: classesURL)
 }

 static func run(_ image: UIImage) async throws -> [rHit] {
  try await Task.detached(priority: .userInitiated) {
   // Honour camera orientation, mirrored images, UIKit scale and CI-backed images.
   let scale = min(1.0, 2048.0 / max(image.size.width, image.size.height))
   let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
   guard size.width >= 1, size.height >= 1 else { throw CocoaError(.fileReadCorruptFile) }
   let format = UIGraphicsImageRendererFormat()
   format.scale = 1
   format.opaque = true
   let normal = UIGraphicsImageRenderer(size: size, format: format).image { context in
    UIColor.black.setFill()
    context.fill(CGRect(origin: .zero, size: size))
    image.draw(in: CGRect(origin: .zero, size: size))
   }
   guard let cgImage = normal.cgImage else { throw CocoaError(.fileReadCorruptFile) }
   return try classifier.get().suggestions(for: cgImage)
  }.value
 }
}
struct rCam:UIViewControllerRepresentable {
 var got:(UIImage)->Void;@Environment(\.dismiss) var dismiss
 func makeCoordinator()->rC{rC(self)}
 func makeUIViewController(context:Context)->UIImagePickerController{let p=UIImagePickerController();p.sourceType = .camera;p.cameraCaptureMode = .photo;p.delegate=context.coordinator;return p}
 func updateUIViewController(_ p:UIImagePickerController,context:Context){}
 final class rC:NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate {let host:rCam;init(_ h:rCam){host=h};func imagePickerControllerDidCancel(_ picker:UIImagePickerController){host.dismiss()};func imagePickerController(_ picker:UIImagePickerController,didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey:Any]){if let i=info[.originalImage] as? UIImage{host.got(i)};host.dismiss()}}
}
struct rScan:View {
 @EnvironmentObject var z:rZ
 var img:UIImage;var sample=false
 @Environment(\.dismiss) var dismiss
 @State private var hits:[rHit]=[];@State private var selected="";@State private var note="";@State private var busy=true;@State private var failed=false;@State private var manual=false;@FocusState private var editing:Bool
 var body:some View{
  NavigationStack{ScrollView{VStack(alignment:.leading,spacing:20){
   Image(uiImage:img).resizable().scaledToFit().frame(maxHeight:300).frame(maxWidth:.infinity).background(rDeep).clipShape(RoundedRectangle(cornerRadius:24))
   if sample {Label(rL("sampleNotice"),systemImage:"info.circle").font(.caption);Text(rL("sampleNotSaved")).font(.caption)}
   if busy{ProgressView(rL("analyzing")).padding(30).frame(maxWidth:.infinity)}else{
    Text(rL("suggestions")).font(.title2.bold());if let e=z.alert{Text(e).font(.footnote).foregroundStyle(rDeep)}
    Text(rL(failed ? "mlError" : hits.isEmpty ? "noFishMatch" : "score")).font(.footnote).foregroundStyle(.secondary)
    if let score = hits.first?.score, score < 0.5{Text(rL("uncertain")).font(.callout).padding().background(rSand,in:RoundedRectangle(cornerRadius:18))}
    ForEach(hits){h in Button{selected=h.latin}label:{HStack{VStack(alignment:.leading){Text(rK.find(h.latin).map{rL($0.name)} ?? h.latin).font(.headline);Text(h.latin).font(.caption).italic()};Spacer();Text(h.score,format:.percent.precision(.fractionLength(0))).monospacedDigit();Image(systemName:selected==h.latin ? "checkmark.circle.fill":"circle")}.padding(16).frame(maxWidth:.infinity).background(selected==h.latin ? rSand:Color.white,in:RoundedRectangle(cornerRadius:18))}.buttonStyle(.plain).accessibilityIdentifier("candidate-\(h.id)")}
    if !selected.isEmpty,let f=rK.find(selected){rPanel{rLabel(text:"marks");Text(rL(f.marks));NavigationLink(rL(f.name)){rProfile(f:f)}}}else if !selected.isEmpty{Text(rL("noProfile")).font(.footnote)}
    Button(rL("select")){manual=true}.buttonStyle(.bordered).accessibilityIdentifier("manualSpecies")
    TextField(rL("notes"),text:$note,axis:.vertical).focused($editing).accessibilityIdentifier("fieldNote").lineLimit(3...6).padding().background(.white,in:RoundedRectangle(cornerRadius:16))
    if sample{Button { dismiss() } label: { Text(rL("done")).foregroundStyle(.white) }.buttonStyle(.borderedProminent).tint(rBlue)}else{Button{if z.save(img,latin:selected,note:note){dismiss();z.tab=2}}label:{Label(rL("confirm"),systemImage:"checkmark").foregroundStyle(rDeep).frame(maxWidth:.infinity).padding(10)}.buttonStyle(.borderedProminent).tint(rOrange).disabled(selected.isEmpty).accessibilityIdentifier("saveFind")}
   }
  }.padding(20).frame(maxWidth:780).frame(maxWidth:.infinity)}.scrollDismissesKeyboard(.interactively).background(rPaper).navigationTitle(rL("identify")).navigationBarTitleDisplayMode(.inline).toolbar{ToolbarItem(placement:.cancellationAction){Button(rL("cancel")){dismiss()}};ToolbarItemGroup(placement:.keyboard){Spacer();Button(rL("done")){editing=false}.accessibilityIdentifier("dismissKeyboard")}}}
  .task{do{hits=try await rRead.run(img);if !sample{z.scan()}}catch{failed=true};busy=false}
  .sheet(isPresented:$manual){NavigationStack{List(rK.all){f in Button{selected=f.latin;manual=false}label:{VStack(alignment:.leading){Text(rL(f.name));Text(f.latin).font(.caption).foregroundStyle(.secondary)}}}.navigationTitle(rL("select")).toolbar{Button(rL("cancel")){manual=false}}}}
 }
}
