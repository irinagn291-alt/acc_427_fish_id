"""Refresh plist metadata from the shipping localisation and field-guide resources."""
from pathlib import Path
import json
import plistlib

p = Path(__file__).resolve().parent.parent
r = p / "ReefLens/Resources"
species = json.loads((r / "species.json").read_text())
classes = set(json.loads((r / "FishClasses.json").read_text()).values())
catalog = json.loads((r / "Localizable.xcstrings").read_text())["strings"]
if {fish["latin"] for fish in species if fish["photoSupported"]} != classes:
    raise ValueError("The illustrated atlas and photo-identification taxonomy disagree")
for fish in species:
    for field in ("name", "marks", "habitat", "season", "nativeRange"):
        if field in fish and fish[field] not in catalog:
            raise ValueError(f"Missing translated {field} for {fish['latin']}")

permissions = json.loads((r / "InfoPlist.xcstrings").read_text())["strings"]
P = {key: {"en": item["localizations"]["en"]["stringUnit"]["value"]}
     for key, item in permissions.items()}
for file,widget in [('AppInfo.plist',False),('WidgetInfo.plist',True)]:
 d={'CFBundleDisplayName':'Fish ID','CFBundleIdentifier':'$(PRODUCT_BUNDLE_IDENTIFIER)','CFBundleExecutable':'$(EXECUTABLE_NAME)','CFBundleName':'$(PRODUCT_NAME)','CFBundlePackageType':'XPC!' if widget else 'APPL','CFBundleShortVersionString':'$(MARKETING_VERSION)','CFBundleVersion':'$(CURRENT_PROJECT_VERSION)'}
 if widget: d['NSExtension']={'NSExtensionPointIdentifier':'com.apple.widgetkit-extension'}
 else: d.update({'LSRequiresIPhoneOS':True,'UILaunchScreen':{},'UISupportedInterfaceOrientations':['UIInterfaceOrientationPortrait','UIInterfaceOrientationLandscapeLeft','UIInterfaceOrientationLandscapeRight'],'UISupportedInterfaceOrientations~ipad':['UIInterfaceOrientationPortrait','UIInterfaceOrientationPortraitUpsideDown','UIInterfaceOrientationLandscapeLeft','UIInterfaceOrientationLandscapeRight'],'CFBundleURLTypes':[{'CFBundleURLSchemes':['fishid']}],**{k:v['en'] for k,v in P.items()}})
 (p/'ReefLens'/file).write_bytes(plistlib.dumps(d))
for file,ent in [('App.entitlements',{'com.apple.security.application-groups':['group.com.fishid.app-833450b6cc07']}),('Widget.entitlements',{'com.apple.security.application-groups':['group.com.fishid.app-833450b6cc07']})]: (p/'ReefLens'/file).write_bytes(plistlib.dumps(ent))
privacy={'NSPrivacyTracking':False,'NSPrivacyCollectedDataTypes':[],'NSPrivacyAccessedAPITypes':[]}
(r/'PrivacyInfo.xcprivacy').write_bytes(plistlib.dumps(privacy))
