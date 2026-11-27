import WidgetKit
import SwiftUI
struct rEntry:TimelineEntry {var date:Date;var state:rS}
struct rProvider:TimelineProvider {
 func placeholder(in context:Context)->rEntry {rEntry(date:.now,state:rS())}
 func getSnapshot(in context:Context,completion:@escaping(rEntry)->Void){completion(rEntry(date:.now,state:rS.read()))}
 func getTimeline(in context:Context,completion:@escaping(Timeline<rEntry>)->Void){let now=Date();let next=Calendar.current.startOfDay(for:Calendar.current.date(byAdding:.day,value:1,to:now)!);completion(Timeline(entries:[rEntry(date:now,state:rS.read()),rEntry(date:next,state:rS.read())],policy:.after(next)))}
}
struct rWidgetFace:View {
 var entry:rEntry;var forced:WidgetFamily? = nil;@Environment(\.widgetFamily)var automatic;var family:WidgetFamily{forced ?? automatic}
 var body:some View {
  let f=rK.day(entry.date)
  Group{switch family{
  case .accessoryInline:Text(rL("day")+": "+rL(f.name))
  case .accessoryCircular:Image(systemName:"fish.fill").overlay(alignment:.bottom){Text(rL(f.name)).font(.system(size:8)).lineLimit(1)}
  case .accessoryRectangular:VStack(alignment:.leading){Text(rL("day")).font(.caption2);Text(rL(f.name)).font(.headline);Text(f.latin).font(.caption2).italic()}
  case .systemSmall:VStack(alignment:.leading,spacing:5){rLabel(text:"day").foregroundStyle(rSand);rFish(seed:f.id,bright:true).frame(maxHeight:.infinity);Text(rL(f.name)).font(.headline);Text(f.latin).font(.system(size:9)).italic().foregroundStyle(rSand)}.foregroundStyle(.white)
  case .systemMedium:VStack(alignment:.leading,spacing:8){HStack{Text("Fish ID").font(.headline);Spacer();Text(rL("stats")).font(.caption)};HStack(alignment:.bottom){VStack(alignment:.leading){Text("\(entry.state.weekly)").font(.system(size:40,weight:.bold,design:.rounded));Text(rL("week")).font(.caption)};Spacer();HStack(alignment:.bottom,spacing:8){ForEach(Array(entry.state.bars.enumerated()),id:\.offset){i,n in VStack{RoundedRectangle(cornerRadius:4).fill(rOrange.opacity(n>0 ? 1:0.15)).frame(width:16,height:CGFloat(max(3,min(n*10,55))));Text(Calendar.current.date(byAdding:.day,value:i-6,to:entry.date)!,format:.dateTime.weekday(.narrow)).font(.system(size:9))}}}}}
  default:VStack(alignment:.leading,spacing:6){
   HStack{VStack(alignment:.leading,spacing:3){rLabel(text:"day");Text(rL(f.name)).font(.headline).lineLimit(2);Text(f.latin).font(.caption2).italic().lineLimit(1)};Spacer();rFish(seed:f.id).frame(width:95,height:56)}
   Divider()
   VStack(alignment:.leading,spacing:4){Text(rL("favorites")).font(.caption.bold());let favorites=rK.all.filter{entry.state.favorites.contains($0.id)};Text(favorites.isEmpty ? rL("emptyFav"):favorites.prefix(3).map{rL($0.name)}.joined(separator:" · ")).font(.caption).lineLimit(2)}
   VStack(alignment:.leading,spacing:4){HStack{Text(rL("recent")).font(.caption.bold());Spacer();Text("\(entry.state.count)").font(.caption.bold())};Text(entry.state.recent.isEmpty ? rL("empty"):entry.state.recent.prefix(2).map{latin in rK.find(latin).map{rL($0.name)} ?? latin}.joined(separator:" · ")).font(.caption).lineLimit(1)}
   Spacer(minLength:0)
   HStack{Image(systemName:"leaf");Text(rL(f.season)).bold();Spacer();Text(rL(f.season == "liveYoung" || f.season == "reefLife" ? "breeding" : "spawn")).font(.system(size:9)).multilineTextAlignment(.trailing).lineLimit(2)}.font(.caption).padding(8).background(rSand,in:RoundedRectangle(cornerRadius:12))}

  }}.containerBackground(for:.widget){family == .systemSmall ? AnyView(rDeep):AnyView(rPaper)}.widgetURL(URL(string:family == .systemMedium ? "fishid://finds":"fishid://species/\(f.id)"))
 }
}
#if RILL_WIDGET
@main struct rTide:Widget {var body:some WidgetConfiguration{StaticConfiguration(kind:"RillFieldNotes",provider:rProvider()){rWidgetFace(entry:$0)}.configurationDisplayName(rL("widgetName")).description(rL("widgetDesc")).supportedFamilies([.systemSmall,.systemMedium,.systemLarge,.accessoryCircular,.accessoryInline,.accessoryRectangular])}}

#endif
