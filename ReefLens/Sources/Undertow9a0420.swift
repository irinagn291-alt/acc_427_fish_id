import SwiftUI
import WidgetKit

func rL(_ k:String)->String { NSLocalizedString(k,comment:"") }
let rGroup="group.com.fishid.app-833450b6cc07"
let rBlue=Color(red:0.055,green:0.353,blue:0.655)
let rDeep=Color(red:0.024,green:0.184,blue:0.333)
let rOrange=Color(red:0.976,green:0.451,blue:0.086)
let rSand=Color(red:0.957,green:0.894,blue:0.757)
let rPaper=Color(red:0.966,green:0.968,blue:0.948)
struct rK:Codable,Identifiable,Hashable {
 var id:String; var latin:String; var name:String; var size:String; var habitat:String; var marks:String; var season:String; var nativeRange:String?; var photoSupported:Bool
 static let all:[rK] = { guard let u=Bundle.main.url(forResource:"species",withExtension:"json"),let d=try? Data(contentsOf:u),let v=try? JSONDecoder().decode([rK].self,from:d) else { return [] };return v }()
 static func day(_ d:Date = .now)->rK { all[abs(Calendar.current.ordinality(of:.day,in:.era,for:d) ?? 0) % max(1,all.count)] }
 static func find(_ latin:String)->rK? { all.first{$0.latin==latin} }
}
struct rF:Codable,Identifiable { var id:UUID;var latin:String;var date:Date;var photo:String;var note:String }
struct rD:Codable {var finds:[rF]=[];var scans:[Date]=[];var favorites:[String]=[];var reminds=false}
struct rS:Codable {
 var dates:[Date]=[];var favorites:[String]=[];var recent:[String]=[];var count=0
 static var url:URL? { FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:rGroup)?.appendingPathComponent("tide.json") }
 static func read()->rS {guard let u=url,let d=try? Data(contentsOf:u),let x=try? JSONDecoder().decode(rS.self,from:d) else {return rS()};return x}
 var weekly:Int {dates.filter{Calendar.current.isDate($0,equalTo:.now,toGranularity:.weekOfYear)}.count}
 var bars:[Int] {let cal=Calendar.current;return (0..<7).map{ n in let d=cal.date(byAdding:.day,value:n-6,to:.now)!;return dates.filter{cal.isDate($0,inSameDayAs:d)}.count}}
}
struct rFish:View {
 var seed:String="perch"; var bright=false
 var body:some View {
  Canvas { c, s in
   let w=s.width,h=s.height
   func p(_ points:[CGPoint])->Path{Path{p in guard let f=points.first else{return};p.move(to:f);for x in points.dropFirst(){p.addLine(to:x)};p.closeSubpath()}}
   func pt(_ x:CGFloat,_ y:CGFloat)->CGPoint{CGPoint(x:x*w,y:y*h)}
   let long = seed == "pike"
   let sunfish = ["bluegill","green","pumpkin","redbreast"].contains(seed)
   let minnow = ["western","eastern","creek"].contains(seed)
   let deep = sunfish || ["crappie","carp","idol"].contains(seed)
   let trout = ["rainbow", "brook", "brown"].contains(seed)
   let nose: CGFloat = (long || seed == "idol") ? 0.95 : 0.87
   let dorsal: CGFloat = deep ? 0.10 : ((long || minnow) ? 0.32 : 0.21)
   let belly: CGFloat = deep ? 0.93 : (long || minnow ? 0.72 : 0.82)
   let body = Path { path in
     path.move(to:pt(0.16,0.50))
     path.addCurve(to:pt(nose,0.47),control1:pt(0.36,dorsal),control2:pt(long ? 0.68 : 0.70,dorsal - 0.05))
     path.addCurve(to:pt(0.16,0.53),control1:pt(long ? 0.79 : 0.71,belly),control2:pt(0.37,belly))
     path.closeSubpath()
   }
   let colours: [String: Color] = [
     "largemouth":Color(red:0.32,green:0.46,blue:0.24),
     "yellow":Color(red:0.81,green:0.62,blue:0.14), "western":Color(red:0.51,green:0.50,blue:0.37),
     "eastern":Color(red:0.47,green:0.48,blue:0.38), "channel":Color(red:0.29,green:0.39,blue:0.43),
     "redbreast":Color(red:0.38,green:0.48,blue:0.33), "green":Color(red:0.25,green:0.43,blue:0.33),
     "pumpkin":Color(red:0.52,green:0.53,blue:0.27), "creek":Color(red:0.43,green:0.43,blue:0.30),
     "idol":Color(red:0.91,green:0.74,blue:0.20), "bass":.init(red:0.28,green:0.42,blue:0.22), "smallmouth":.init(red:0.60,green:0.39,blue:0.20),
     "tench":.init(red:0.35,green:0.42,blue:0.13), "carp":.init(red:0.63,green:0.45,blue:0.21),
     "bluegill":.init(red:0.24,green:0.47,blue:0.48), "pike":.init(red:0.35,green:0.49,blue:0.22),
     "perch":.init(red:0.31,green:0.54,blue:0.32), "walleye":.init(red:0.53,green:0.49,blue:0.23),
     "brown":.init(red:0.56,green:0.36,blue:0.19), "brook":.init(red:0.21,green:0.37,blue:0.30),
     "rainbow":.init(red:0.33,green:0.46,blue:0.52), "crappie":.init(red:0.42,green:0.51,blue:0.46)
   ]
   let a = colours[seed] ?? rBlue
   let fin = ["perch","yellow","redbreast","bluegill","brook"].contains(seed) ? rOrange : a
   if minnow && seed != "creek" {
     c.fill(Path(ellipseIn:CGRect(x:w*0.04,y:h*0.36,width:w*0.17,height:h*0.30)),with:.color(a))
   } else {
     c.fill(p([pt(0.23,0.50),pt(0.035,0.25),pt(seed == "channel" ? 0.15 : 0.074,0.50),pt(0.042,0.76)]),with:.linearGradient(Gradient(colors:[fin,rSand]),startPoint:pt(0.06,0.26),endPoint:pt(0.21,0.64)))
   }
   if seed == "idol" {
     let streamer=Path { path in
       path.move(to:pt(0.66,0.29))
       path.addQuadCurve(to:pt(0.27,0.015),control:pt(0.62,-0.03))
       path.addQuadCurve(to:pt(0.58,0.31),control:pt(0.56,0.10))
     }
     c.fill(streamer,with:.color(.white)); c.stroke(streamer,with:.color(rDeep.opacity(0.42)),lineWidth:max(0.8,w/310))
   } else if trout || long || minnow || seed == "channel" {
     let start: CGFloat = (long || seed == "eastern" || seed == "western") ? 0.23 : 0.40
     c.fill(p([pt(start,0.37),pt(start+0.04,0.14),pt(start+0.16,0.35)]),with:.color(a))
   } else {
     c.fill(p([pt(0.32,0.35),pt(0.36,0.15),pt(0.40,0.22),pt(0.44,0.08),pt(0.48,0.20),pt(0.54,0.10),pt(0.63,0.30)]),with:.color(a))
   }
   c.fill(p([pt(0.40,0.65),pt(0.31,0.83),pt(0.54,0.70)]),with:.color(fin))
   c.fill(p([pt(0.62,0.65),pt(0.59,0.84),pt(0.73,0.65)]),with:.color(fin))
   c.fill(body,with:.linearGradient(Gradient(colors:[a,a.opacity(0.8),bright ? rSand : .init(red:0.84,green:0.84,blue:0.67),.white]),startPoint:pt(0.45,0.22),endPoint:pt(0.5,0.80)))
   var clipped=c;clipped.clip(to:body)
   if ["perch","yellow","smallmouth","walleye","bluegill"].contains(seed) {
     for i in 0..<6 {
       let x=0.28+CGFloat(i)*0.075
       clipped.fill(p([pt(x,0.22),pt(x+0.045,0.23),pt(x+0.035,0.63),pt(x+0.014,0.59)]),with:.color(rDeep.opacity(0.5)))
     }
   }
   let flecked = trout || ["pike","crappie","channel","pumpkin"].contains(seed)
   for row in 0..<6 {
     for col in 0..<15 {
       let x = 0.21 + CGFloat(col)*0.043 + (row.isMultiple(of:2) ? 0.019:0)
       let y = 0.27 + CGFloat(row)*0.073
       var scales=Path()
       scales.move(to:pt(x,y))
       scales.addQuadCurve(to:pt(x,y+0.070),control:pt(x+0.022,y+0.034))
       clipped.stroke(scales,with:.color(.white.opacity(seed == "carp" ? 0.42 : 0.15)),lineWidth:max(0.6,w/440))
       if flecked && (row*7 + col*11)%4 < 2 {
         let tint: Color = seed == "pumpkin" ? rOrange : (seed == "pike" ? rSand : (seed == "brown" && col.isMultiple(of:3) ? .red : rDeep))
         clipped.fill(Path(ellipseIn:CGRect(x:x*w,y:y*h,width:w*(long ? 0.022:0.012),height:h*0.024)),with:.color(tint.opacity(0.76)))
       }
     }
   }
   if ["bass","largemouth","creek","rainbow"].contains(seed) {
     clipped.stroke(Path { line in line.move(to:pt(0.16,0.51));line.addQuadCurve(to:pt(0.74,0.48),control:pt(0.46,0.45)) },with:.color(seed == "rainbow" ? .pink.opacity(0.64) : .black.opacity(0.52)),lineWidth:h*0.052)
   }
   func oval(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat)->Path {
     Path(ellipseIn:CGRect(x:x*w,y:y*h,width:width*w,height:height*h))
   }
   if sunfish {
     if seed == "redbreast" {
       clipped.fill(oval(0.43,0.57,0.38,0.28),with:.color(rOrange.opacity(0.82)))
     }
     let earWidth:CGFloat = seed == "redbreast" ? 0.10 : 0.056
     clipped.fill(oval(0.69-earWidth,0.46,earWidth,0.077),with:.color(rDeep))
     if seed == "pumpkin" { clipped.fill(oval(0.621,0.467,0.020,0.063),with:.color(rOrange)) }
     if ["pumpkin","green"].contains(seed) {
       for bar in 0..<3 {
         let y=0.49+CGFloat(bar)*0.036
         clipped.stroke(Path { path in
           path.move(to:pt(0.69,y))
           path.addQuadCurve(to:pt(0.79,y+0.006),control:pt(0.74,y-0.025))
         },with:.color(.cyan.opacity(0.75)),lineWidth:max(1,h*0.014))
       }
     }
   }
   if seed == "western" || seed == "eastern" {
     clipped.fill(oval(0.34,0.54,0.063,0.068),with:.color(rDeep.opacity(0.78)))
   }
   if seed == "creek" { clipped.fill(oval(0.51,0.315,0.036,0.07),with:.color(rDeep)) }
   if seed == "idol" {
     for x in [CGFloat(0.28),0.59] {
       clipped.fill(p([pt(x,0.12),pt(x+0.07,0.12),pt(x+0.17,0.88),pt(x+0.06,0.88)]),with:.color(rDeep))
     }
     clipped.fill(p([pt(0.43,0.12),pt(0.55,0.12),pt(0.61,0.9),pt(0.54,0.9)]),with:.color(.white))
   }
   if seed == "channel" || seed == "carp" {
     for whisker in 0..<(seed == "channel" ? 4 : 2) {
       let n=CGFloat(whisker)
       c.stroke(Path { path in
         path.move(to:pt(0.84,0.51+n*0.014))
         path.addQuadCurve(to:pt(0.72+n*0.045,0.66+n*0.026),control:pt(0.86+n*0.012,0.61))
       },with:.color(bright ? rSand : rDeep),lineWidth:max(0.9,w/215))
     }
   }
   c.stroke(Path{p in p.move(to:pt(0.69,0.35));p.addQuadCurve(to:pt(0.68,0.67),control:pt(0.61,0.51))},with:.color(rDeep.opacity(0.3)),lineWidth:2)
   c.fill(p([pt(0.61,0.5),pt(0.46,0.62),pt(0.55,0.65)]),with:.color(a.opacity(0.8)))
   c.fill(Path(ellipseIn:CGRect(x:w*0.758,y:h*0.394,width:w*0.033,height:w*0.033)),with:.color(rSand))
   c.fill(Path(ellipseIn:CGRect(x:w*0.767,y:h*0.406,width:w*0.017,height:w*0.017)),with:.color(rDeep))
   c.stroke(Path{p in p.move(to:pt(0.82,0.52));p.addLine(to:pt(0.86,0.49))},with:.color(rDeep),lineWidth:2)
  }.accessibilityLabel(rL("illustration"))
 }
}
struct rPanel<Z:View>:View { @ViewBuilder var content:Z;var body:some View{VStack(alignment:.leading,spacing:14){content}.padding(20).frame(maxWidth:.infinity,alignment:.leading).background(.white,in:RoundedRectangle(cornerRadius:24))}}
struct rLabel:View {var text:String;var body:some View{Text(rL(text)).font(.system(size:11,weight:.bold,design:.monospaced)).tracking(1.6)}}
