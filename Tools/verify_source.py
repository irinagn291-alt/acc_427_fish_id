from pathlib import Path
import json,re,getpass
p=Path(__file__).resolve().parent.parent
s=json.loads((p/'ReefLens/Resources/Localizable.xcstrings').read_text())['strings']
used=set()
for f in (p/'ReefLens/Sources').glob('*.swift'):
 txt=f.read_text();assert not re.search(r'/Users/|'+re.escape(getpass.getuser())+r'|\bContentView\b|\bMyApp\b|\bViewModel\b|\bManager\b',txt),f
 used.update(re.findall(r'rL\("([^"\\]+)"\)',txt));used.update(re.findall(r'rLabel\(text:"([^"\\]+)"',txt))
assert not used-s.keys(),used-s.keys()
assert all(set(v['localizations'])=={'en','en-GB','en-US','de','fr','es','ar','zh-Hant'} for v in s.values())
for f in (p/'Store').glob('*.json'):
 d=json.loads(f.read_text())
 if 'subtitle' in d:assert len(d['subtitle'])<=30,(f,len(d['subtitle']))
 if 'keywords' in d:assert len(d['keywords'])<=100
project=(p/'FishID.xcodeproj/project.pbxproj').read_text()
source_paths={str(path.relative_to(p)) for path in (p/'ReefLens/Sources').glob('*.swift')}
assert source_paths==set(re.findall(r'path = (ReefLens/Sources/[^;]+\.swift);',project))
resources=p/'ReefLens/Resources'
for name in ['INatVision_Small_2_fact256_8bit.mlmodel','iNaturalist_LICENSE.txt',
             'FishClasses.json','sample_rainbow.jpg']:
 assert (resources/name).is_file() and 'ReefLens/Resources/'+name in project,name
for historical in ['RillNet.mlpackage','sample_tench.png','Fishial_LICENSE.txt']:
 assert not (resources/historical).exists() and historical not in project,historical
classes=json.loads((resources/'FishClasses.json').read_text())
assert len(classes)==17 and all(0<=int(key)<507 for key in classes) and len(set(classes.values()))==17
print('Source, localization and metadata checks passed.')
