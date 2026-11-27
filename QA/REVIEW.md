# Release review notes

Fish ID uses bundle ID com.fishid.app-833450b6cc07 and App Group group.com.fishid.app-833450b6cc07. The iPhone/iPad application and its WidgetKit extension ship a local atlas. The Photos picker works with selected images. Camera access is requested on demand, and photo export requests add-only access. Local reminders use UserNotifications. The shipping build has no remote-notification background mode or push entitlement.

On first use, choose **Try a sample photo**. Core ML processes Sam Stukel’s public-domain USFWS rainbow trout photograph on the device. The top-ranked scientific name is *Oncorhynchus mykiss*. Select a different candidate to inspect its field marks. The sample stays out of personal observations. A personal image can be saved, edited, exported as a field card, and deleted locally.

The profile pages include photo-recognition scope, illustration, visible field marks, typical length, habitat, range and breeding or early life. The atlas has 22 species and permits manual selection for every species. All 17 fish outputs of the iNaturalist model are covered. Model scores in the UI retain their original values.

QA/RillChecks.swift exercises photo inference, navigation, record persistence, favourite persistence, permissions, widget previews and supported interface languages. The six marketing routes exist only in Debug. Archived UI-test runs from 15 November exercised the earlier model. Current release evidence is under .artifacts/nov27-release/Fish in the factory workspace.
