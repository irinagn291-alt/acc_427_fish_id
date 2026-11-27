from pathlib import Path
from zipfile import ZipFile,ZIP_DEFLATED
import json,hashlib
p=Path(__file__).resolve().parent.parent
files=[]
for folder in ['ReefLens','FishID.xcodeproj','QA','Store']:
 files.extend(f for f in (p/folder).rglob('*') if f.is_file() and not any(x in f.parts for x in ['xcuserdata','.DS_Store']))
files += [p/f for f in ['SOURCES.md','REPORT.md','.gitignore'] if (p/f).exists()]
files += [p/'Tools'/f for f in ['project.py','make_data.py','qa-phone.sh','qa-pad.sh','package.py','verify_source.py']]
with ZipFile(p/'Build/FishID-source.zip','w',ZIP_DEFLATED) as z:
 for f in files:z.write(f,f.relative_to(p))
manifest={str(f.relative_to(p)):hashlib.sha256(f.read_bytes()).hexdigest() for f in files}
(p/'Build/source-manifest.json').write_text(json.dumps(manifest,indent=2))
print('Packaged',len(files),'source files')
