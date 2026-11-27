from pathlib import Path
import uuid,json,re,plistlib
from PIL import Image,ImageDraw
p=Path(__file__).resolve().parent.parent; src=p/'ReefLens/Sources'
for f in src.glob('*.swift'):
 s=f.read_text();s=re.sub(r'(?<![\w.])\.(\d)',r'0.\1',s);f.write_text(s)
# Rasterize this project's original geometric icon.
n=1024;im=Image.new('RGB',(n,n));pix=im.load()
for y in range(n):
 for x in range(n):
  k=(x+y)/(2*n);pix[x,y]=(int(6+8*k),int(47+43*k),int(85+82*k))
d=ImageDraw.Draw(im)
for box in [(220,220,804,804),(280,280,744,744)]:
 x,y,a,b=box;L=85
 if x==220:
  for pts in [[(x,y+L),(x,y),(x+L,y)],[(a-L,y),(a,y),(a,y+L)],[(x,b-L),(x,b),(x+L,b)],[(a-L,b),(a,b),(a,b-L)]]:d.line(pts,fill='#F4E4C1',width=19,joint='curve')
d.polygon([(315,520),(190,395),(200,650)],fill='#F97316')
d.polygon([(410,355),(450,255),(480,330),(520,265),(575,360)],fill='#82C6AF')
d.ellipse((290,350,822,685),fill='#A5D6BC');d.polygon([(535,610),(475,745),(655,650)],fill='#F97316')
d.ellipse((705,442,753,490),fill='#062F55');d.ellipse((715,447,727,460),fill='#FFFFFF')
for y in [410,510,610]:d.line([(280,y),(800,y)],fill='#F4E4C1',width=4)
a=p/'ReefLens/Assets.xcassets';a.mkdir(exist_ok=True);(a/'Contents.json').write_text(json.dumps({'info':{'version':1,'author':'xcode'}}));i=a/'AppIcon.appiconset';i.mkdir(exist_ok=True);im.save(i/'RillMark.png');(i/'Contents.json').write_text(json.dumps({'images':[{'idiom':'universal','platform':'ios','size':'1024x1024','filename':'RillMark.png'}],'info':{'version':1,'author':'xcode'}}))
objs={}
def new(isa,**v):
 u=uuid.uuid4().hex[:24].upper();objs[u]={'isa':isa,**v};return u
def ref(path,kind):return new('PBXFileReference',lastKnownFileType=kind,path=path,sourceTree='<group>')
def bfile(ref,**settings):return new('PBXBuildFile',fileRef=ref,**({'settings':settings} if settings else {}))
appsrc=[ref('ReefLens/Sources/'+n,'sourcecode.swift') for n in ['Shoal7917d0.swift','Undertow9a0420.swift','Lens.swift','Ledger.swift','FishClassifier.swift']]
widgetsrc=[appsrc[1],ref('ReefLens/Sources/TideWidget.swift','sourcecode.swift')]
appsrc.append(widgetsrc[1])
resources=[ref('ReefLens/Resources/'+n,k) for n,k in [('species.json','text.json'),('Localizable.xcstrings','text.json.xcstrings'),('PrivacyInfo.xcprivacy','text.xml'),('sample_rainbow.jpg','image.jpeg'),('iNaturalist_LICENSE.txt','text'),('INatVision_Small_2_fact256_8bit.mlmodel','file.mlmodel'),('FishClasses.json','text.json')]]
info=ref('ReefLens/Resources/InfoPlist.xcstrings','text.json.xcstrings');assets=ref('ReefLens/Assets.xcassets','folder.assetcatalog')
prodapp=new('PBXFileReference',explicitFileType='wrapper.application',path='Fish ID.app',sourceTree='BUILT_PRODUCTS_DIR');prodext=new('PBXFileReference',explicitFileType='wrapper.app-extension',path='RillTide.appex',sourceTree='BUILT_PRODUCTS_DIR');prodtest=new('PBXFileReference',explicitFileType='wrapper.cfbundle',path='RillChecks.xctest',sourceTree='BUILT_PRODUCTS_DIR')
project=uuid.uuid4().hex[:24].upper()
base={'IPHONEOS_DEPLOYMENT_TARGET':'17.4','SWIFT_VERSION':'5.0','SDKROOT':'iphoneos','TARGETED_DEVICE_FAMILY':'1,2','CODE_SIGN_STYLE':'Automatic','CLANG_ENABLE_MODULES':'YES','SWIFT_STRICT_CONCURRENCY':'minimal','MARKETING_VERSION':'1.3.0','CURRENT_PROJECT_VERSION':'2037','ENABLE_USER_SCRIPT_SANDBOXING':'YES','ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS':'NO'}
def configs(extra):
 ids=[]
 for name in ['Debug','Release']:
  vals={**base,**extra,'SWIFT_OPTIMIZATION_LEVEL':'-Onone' if name=='Debug' else '-O','DEBUG_INFORMATION_FORMAT':'dwarf' if name=='Debug' else 'dwarf-with-dsym'}
  if name=='Debug':vals['SWIFT_ACTIVE_COMPILATION_CONDITIONS']='DEBUG '+extra.get('SWIFT_ACTIVE_COMPILATION_CONDITIONS','')
  ids.append(new('XCBuildConfiguration',name=name,buildSettings=vals))
 return new('XCConfigurationList',buildConfigurations=ids,defaultConfigurationIsVisible='0',defaultConfigurationName='Release')
def phase(isa,files):return new(isa,buildActionMask='2147483647',files=[bfile(f) for f in files],runOnlyForDeploymentPostprocessing='0')
ext=new('PBXNativeTarget',name='RillTide',productName='RillTide',productType='com.apple.product-type.app-extension',productReference=prodext,buildConfigurationList=configs({'PRODUCT_NAME':'$(TARGET_NAME)','PRODUCT_BUNDLE_IDENTIFIER':'com.fishid.app-833450b6cc07.tide','INFOPLIST_FILE':'ReefLens/WidgetInfo.plist','CODE_SIGN_ENTITLEMENTS':'ReefLens/Widget.entitlements','SWIFT_ACTIVE_COMPILATION_CONDITIONS':'RILL_WIDGET','APPLICATION_EXTENSION_API_ONLY':'YES','SKIP_INSTALL':'YES','SWIFT_EMIT_LOC_STRINGS':'NO'}),buildPhases=[phase('PBXSourcesBuildPhase',widgetsrc),phase('PBXResourcesBuildPhase',resources[:3])],buildRules=[],dependencies=[])
proxy=new('PBXContainerItemProxy',containerPortal=project,proxyType='1',remoteGlobalIDString=ext,remoteInfo='RillTide');dep=new('PBXTargetDependency',target=ext,targetProxy=proxy)
embed=new('PBXCopyFilesBuildPhase',buildActionMask='2147483647',dstPath='',dstSubfolderSpec='13',files=[bfile(prodext,ATTRIBUTES=['RemoveHeadersOnCopy'])],name='Embed App Extensions',runOnlyForDeploymentPostprocessing='0')
app=new('PBXNativeTarget',name='RillLens',productName='Fish ID',productType='com.apple.product-type.application',productReference=prodapp,buildConfigurationList=configs({'PRODUCT_NAME':'Fish ID','PRODUCT_MODULE_NAME':'RillLens','PRODUCT_BUNDLE_IDENTIFIER':'com.fishid.app-833450b6cc07','INFOPLIST_FILE':'ReefLens/AppInfo.plist','CODE_SIGN_ENTITLEMENTS':'ReefLens/App.entitlements','ASSETCATALOG_COMPILER_APPICON_NAME':'AppIcon','SWIFT_EMIT_LOC_STRINGS':'NO','SUPPORTS_MACCATALYST':'NO'}),buildPhases=[phase('PBXSourcesBuildPhase',appsrc),phase('PBXResourcesBuildPhase',resources+[info,assets]),embed],buildRules=[],dependencies=[dep])
testfile=ref('QA/RillChecks.swift','sourcecode.swift')
proxy2=new('PBXContainerItemProxy',containerPortal=project,proxyType='1',remoteGlobalIDString=app,remoteInfo='RillLens');dep2=new('PBXTargetDependency',target=app,targetProxy=proxy2)
test=new('PBXNativeTarget',name='RillChecks',productName='RillChecks',productType='com.apple.product-type.bundle.ui-testing',productReference=prodtest,buildConfigurationList=configs({'PRODUCT_NAME':'$(TARGET_NAME)','PRODUCT_BUNDLE_IDENTIFIER':'com.fishid.app-833450b6cc07.checks','GENERATE_INFOPLIST_FILE':'YES','TEST_TARGET_NAME':'RillLens'}),buildPhases=[phase('PBXSourcesBuildPhase',[testfile])],buildRules=[],dependencies=[dep2])
products=new('PBXGroup',children=[prodapp,prodext,prodtest],name='Products',sourceTree='<group>');group=new('PBXGroup',children=list(dict.fromkeys(appsrc+widgetsrc+resources+[info,assets,testfile,products])),sourceTree='<group>')
objs[project]={'isa':'PBXProject','attributes':{'BuildIndependentTargetsInParallel':'YES','LastUpgradeCheck':'2720','ORGANIZATIONNAME':'Rill Atlas Studio 8E47','TargetAttributes':{app:{'SystemCapabilities':{'com.apple.ApplicationGroups.iOS':{'enabled':'1'}}},ext:{'SystemCapabilities':{'com.apple.ApplicationGroups.iOS':{'enabled':'1'}}}}},'buildConfigurationList':configs({}),'compatibilityVersion':'Xcode 14.0','developmentRegion':'en','hasScannedForEncodings':'0','knownRegions':['en','en-GB','en-US','ar','zh-Hant','de','fr','es','Base'],'mainGroup':group,'productRefGroup':products,'projectDirPath':'','projectRoot':'','targets':[app,ext,test]}
def val(x):
 if isinstance(x,dict):return '{ '+''.join(val(k)+' = '+val(v)+'; ' for k,v in x.items())+'}'
 if isinstance(x,list):return '( '+', '.join(val(t) for t in x)+', )' if x else '( )'
 s=str(x);return s if re.fullmatch(r'[A-Za-z0-9_./]+',s) else json.dumps(s)
out=p/'FishID.xcodeproj';out.mkdir(exist_ok=True);(out/'project.pbxproj').write_text('// !$*UTF8*$!\n'+val({'archiveVersion':'1','classes':{},'objectVersion':'56','objects':objs,'rootObject':project})+'\n')
s=out/'xcshareddata/xcschemes';s.mkdir(parents=True,exist_ok=True)
b=lambda i,n:f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{i}" BuildableName="{n}" BlueprintName="{objs[i]["name"]}" ReferencedContainer="container:FishID.xcodeproj"/>'
(s/'RillLens.xcscheme').write_text(f'''<?xml version="1.0" encoding="UTF-8"?><Scheme LastUpgradeVersion="2720" version="1.7"><BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{b(app,'Fish ID.app')}</BuildActionEntry></BuildActionEntries></BuildAction><TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES"><Testables><TestableReference skipped="NO">{b(test,'RillChecks.xctest')}</TestableReference></Testables></TestAction><LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0">{b(app,'Fish ID.app')}</BuildableProductRunnable></LaunchAction><ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES"><BuildableProductRunnable runnableDebuggingMode="0">{b(app,'Fish ID.app')}</BuildableProductRunnable></ProfileAction><AnalyzeAction buildConfiguration="Debug"/><ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/></Scheme>''')
