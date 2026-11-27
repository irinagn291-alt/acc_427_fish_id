#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [ -f Evidence/phone.done ]; then exit 0; fi
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcrun simctl boot "$GF_SIMULATOR_UDID"
xcrun simctl bootstatus "$GF_SIMULATOR_UDID" -b
rill_qa_ok=0
for rill_attempt in 1 2 3; do
  xcrun simctl uninstall "$GF_SIMULATOR_UDID" com.fishid.app-833450b6cc07 > /dev/null 2>&1 || true
  rm -f Evidence/phone.retry
  if xcodebuild -project FishID.xcodeproj -scheme RillLens -configuration Debug -destination "id=$GF_SIMULATOR_UDID" -parallel-testing-enabled NO -derivedDataPath Build/DerivedData -resultBundlePath Evidence/PhoneQA.xcresult CODE_SIGNING_ALLOWED=NO test > Evidence/phone-qa.log 2>&1; then
    rill_qa_ok=1
    break
  fi
  mv Evidence/PhoneQA.xcresult "Evidence/PhoneQA-attempt-$rill_attempt.xcresult"
  cp Evidence/phone-qa.log "Evidence/phone-qa-attempt-$rill_attempt.log"
  touch Evidence/phone.needs-retry
  rill_retry_ready=0
  for rill_pause in $(seq 1 36); do
    if [ -f Evidence/phone.retry ]; then rill_retry_ready=1; break; fi
    sleep 5
  done
  rm -f Evidence/phone.needs-retry
  if [ "$rill_retry_ready" != 1 ]; then exit 1; fi
done
if [ "$rill_qa_ok" != 1 ]; then exit 1; fi
xcrun simctl terminate "$GF_SIMULATOR_UDID" com.fishid.app-833450b6cc07 > /dev/null 2>&1 || true
xcrun simctl launch "$GF_SIMULATOR_UDID" com.fishid.app-833450b6cc07 -AppleLanguages '(en)'
sleep 3
xcrun simctl io "$GF_SIMULATOR_UDID" screenshot Evidence/iPhone-home.png
xcrun simctl get_app_container "$GF_SIMULATOR_UDID" com.fishid.app-833450b6cc07 data > Evidence/phone-container.txt
printf 'passed\n' > Evidence/phone.done
xcrun simctl shutdown "$GF_SIMULATOR_UDID"
if [ ! -f Evidence/pad.done ]; then
  rill_factory_root="$(cd ../../../.. && pwd)"
  python3 "$rill_factory_root/gf/genesis/simulator_pool.py" 4671120C-F54F-4008-A170-413F94D007D6 bash Tools/qa-pad.sh
fi
