import torch, torch.nn as nn, coremltools as ct, json
from pathlib import Path
# Original ResNet18 architecture; no application dependency.
class B(nn.Module):
 def __init__(self,i,o,s=1):
  super().__init__(); self.conv1=nn.Conv2d(i,o,3,s,1,bias=False); self.bn1=nn.BatchNorm2d(o); self.relu=nn.ReLU(); self.conv2=nn.Conv2d(o,o,3,1,1,bias=False); self.bn2=nn.BatchNorm2d(o); self.downsample=nn.Sequential(nn.Conv2d(i,o,1,s,bias=False),nn.BatchNorm2d(o)) if s!=1 or i!=o else None
 def forward(self,x):
  z=x if self.downsample is None else self.downsample(x); return self.relu(self.bn2(self.conv2(self.relu(self.bn1(self.conv1(x)))))+z)
class R(nn.Module):
 def __init__(self):
  super().__init__(); self.conv1=nn.Conv2d(3,64,7,2,3,bias=False); self.bn1=nn.BatchNorm2d(64); self.relu=nn.ReLU(); self.maxpool=nn.MaxPool2d(3,2,1); self.layer1=nn.Sequential(B(64,64),B(64,64)); self.layer2=nn.Sequential(B(64,128,2),B(128,128)); self.layer3=nn.Sequential(B(128,256,2),B(256,256)); self.layer4=nn.Sequential(B(256,512,2),B(512,512)); self.avgpool=nn.AdaptiveAvgPool2d((1,1))
 def forward(self,x):
  return self.avgpool(self.layer4(self.layer3(self.layer2(self.layer1(self.maxpool(self.relu(self.bn1(self.conv1(x))))))))).flatten(1)
class E(nn.Module):
 def __init__(self,n):
  super().__init__(); self.backbone=R(); self.embeddings=nn.Linear(512,256); self.fc_parallel=nn.Linear(512,n)
 def forward(self,x):
  x=(x-torch.tensor([.485,.456,.406]).view(1,3,1,1))/torch.tensor([.229,.224,.225]).view(1,3,1,1)
  return torch.softmax(self.fc_parallel(self.backbone(x)),dim=1)
p=Path(__file__).resolve().parent; labs=json.loads((p/'Fishial/labels.json').read_text()); m=E(len(labs)); state=torch.load(p/'Fishial/model.ckpt',map_location='cpu',weights_only=True); print(m.load_state_dict(state,strict=True)); m.eval()
x=torch.rand(1,3,224,224); ts=torch.jit.trace(m,x)
model=ct.convert(ts,inputs=[ct.ImageType(name='image',shape=x.shape,scale=1/255)],classifier_config=ct.ClassifierConfig([labs[str(i)] for i in range(len(labs))]),minimum_deployment_target=ct.target.iOS17,compute_precision=ct.precision.FLOAT16)
model.short_description='Fishial v6 ResNet18 species classifier, FC head. Suggestions require visual confirmation.'
model.author='Fishial / Wye Foundation; Core ML conversion for Fish ID'
model.license='MIT; see Fishial_LICENSE.txt'
model.save(str(p.parent/'ReefLens/Resources/RillNet.mlpackage'))
from PIL import Image
import numpy as np
img=Image.open(p/'Fishial/test_image.png').convert('RGB').resize((224,224))
t=torch.from_numpy(np.asarray(img).copy()).permute(2,0,1).unsqueeze(0).float()/255
scores=m(t).detach().numpy()[0]; pred=model.predict({'image':img})
top=lambda probs: sorted(probs.items(),key=lambda z:z[1],reverse=True)[:5]
pt={labs[str(i)]:float(scores[i]) for i in range(len(labs))}
cp=pred['classLabel_probs']
report={'fixture':'Fishial test_image.png / Tinca tinca','labels':len(labs),'pytorch_top5':top(pt),'coreml_top5':top(cp),'max_absolute_deviation':max(abs(cp[k]-v) for k,v in pt.items()),'top1_equal':top(pt)[0][0]==top(cp)[0][0]}
print(report)
(p.parent/'Evidence/model-validation.json').write_text(json.dumps(report,indent=2))
