//
//  SobesHomeTask7WebSocketUITestsLaunchTests.swift
//  SobesHomeTask7WebSocketUITests
//
//  Created by Anton Lebedev on 02.05.2023.
//

import XCTest

final class SobesHomeTask7WebSocketUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
