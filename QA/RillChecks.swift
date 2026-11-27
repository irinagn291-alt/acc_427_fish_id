import XCTest
final class RillChecks:XCTestCase {
 func testCoreJourney()throws {
  let app=XCUIApplication();app.launchArguments=["-AppleLanguages","(en)","-AppleLocale","en_US"];app.launch()
  XCTAssertTrue(app.buttons["samplePhoto"].waitForExistence(timeout:15));snap("01-identify")
  app.swipeUp();app.buttons["samplePhoto"].tap()
  XCTAssertTrue(app.staticTexts["Possible matches"].waitForExistence(timeout:45))
  XCTAssertTrue(app.buttons.matching(NSPredicate(format:"identifier BEGINSWITH 'candidate-'")).firstMatch.exists)
  snap("02-coreml-results")
  app.swipeUp();app.buttons["Done"].tap()
  app.descendants(matching:.any).matching(NSPredicate(format:"label == %@","Field guide")).firstMatch.tap()
  XCTAssertTrue(app.buttons["species-largemouth"].waitForExistence(timeout:10));snap("03-field-guide")
  app.buttons["species-largemouth"].tap();XCTAssertTrue(app.buttons["favorite"].waitForExistence(timeout:5));app.buttons["favorite"].tap();snap("04-species")
  app.terminate();app.launch();app.descendants(matching:.any).matching(NSPredicate(format:"label == %@","Field guide")).firstMatch.tap();app.switches["Favorites"].tap();XCTAssertTrue(app.buttons["species-largemouth"].waitForExistence(timeout:5));XCTAssertFalse(app.buttons["species-rainbow"].exists)
  app.descendants(matching:.any).matching(NSPredicate(format:"label == %@","My finds")).firstMatch.tap();XCTAssertTrue(app.staticTexts["Your field notebook starts here."].waitForExistence(timeout:5));snap("05-finds-empty")
  app.descendants(matching:.any).matching(NSPredicate(format:"label == %@","Limits")).firstMatch.tap();XCTAssertTrue(app.staticTexts["Offline reference • Florida, USA"].waitForExistence(timeout:5));snap("06-regulations")
 }
 func testFindPersistence()throws {
  let app=XCUIApplication();app.launchArguments=["-AppleLanguages","(en)","-RillImportFixture"];app.launch()
  let hit=app.buttons["candidate-Oncorhynchus mykiss"];XCTAssertTrue(hit.waitForExistence(timeout:45));hit.tap()
  app.swipeUp();let field=app.descendants(matching:.any).matching(identifier:"fieldNote").firstMatch;XCTAssertTrue(field.waitForExistence(timeout:5));field.tap();field.typeText("River observation");if app.buttons["dismissKeyboard"].exists{app.buttons["dismissKeyboard"].tap()};app.swipeUp();app.buttons["saveFind"].tap()
  XCTAssertTrue(app.buttons["findRow"].waitForExistence(timeout:8));XCTAssertTrue(app.staticTexts["River observation"].exists);snap("08-saved-find")
  app.terminate();app.launchArguments=["-AppleLanguages","(en)"];app.launch();app.descendants(matching:.any).matching(NSPredicate(format:"label == %@","My finds")).firstMatch.tap();XCTAssertTrue(app.buttons["findRow"].waitForExistence(timeout:8));app.buttons["findRow"].firstMatch.tap();snap("09-find-card");app.swipeUp();app.buttons["deleteFind"].tap();let ds=app.buttons.matching(NSPredicate(format:"label == %@","Delete find"));ds.element(boundBy:ds.count-1).tap();XCTAssertTrue(app.staticTexts["Your field notebook starts here."].waitForExistence(timeout:8))
 }
 func testWidgets()throws {let app=XCUIApplication();app.launchArguments=["-AppleLanguages","(en)","-RillWidgetPreview"];app.launch();XCTAssertTrue(app.staticTexts["Widget rendering QA"].waitForExistence(timeout:12));snap("10-widgets-small-medium");app.swipeUp();snap("11-widgets-large-lock")}
 func testLanguages()throws {
  for (lang,title) in [("de","Bestimmen"),("fr","Identifier"),("es","Identificar"),("zh-Hant","辨識"),("ar","تعرّف"),("en-GB","Identify"),("en-US","Identify")] {let app=XCUIApplication();app.launchArguments=["-AppleLanguages","(\(lang))","-AppleLocale",lang];app.launch();XCTAssertTrue(app.descendants(matching:.any).matching(NSPredicate(format:"label == %@",title)).firstMatch.waitForExistence(timeout:12));snap("locale-\(lang)");app.terminate()}
 }
 func testPermissionFallback()throws {let app=XCUIApplication();app.launchArguments=["-AppleLanguages","(en)"];app.launch();app.buttons["openCamera"].tap();if app.alerts.firstMatch.waitForExistence(timeout:5){let dont=app.alerts.buttons["Don’t Allow"];if dont.exists{dont.tap()}};XCTAssertTrue(app.buttons["choosePhoto"].waitForExistence(timeout:8));snap("07-camera-fallback")}
 private func snap(_ name:String){let a=XCTAttachment(screenshot:XCUIApplication().screenshot());a.name=name;a.lifetime = .keepAlways;add(a)}
}
