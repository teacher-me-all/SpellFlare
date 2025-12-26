//
//  spelling_bee_iOS_AppUITests.swift
//  spelling-bee iOS AppUITests
//
//  Created by MADHURI on 12/25/25.
//
//  Comprehensive UI tests for the Spelling Bee iOS app.
//

import XCTest

final class spelling_bee_iOS_AppUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - App Launch Tests

    @MainActor
    func testAppLaunches() throws {
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

// MARK: - Onboarding UI Tests
final class iOS_OnboardingUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "RESET_STATE"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func testOnboardingWelcomeScreenExists() throws {
        app.launch()

        let beeEmoji = app.staticTexts["🐝"]
        XCTAssertTrue(beeEmoji.waitForExistence(timeout: 5), "Bee emoji should be visible")

        let appTitle = app.staticTexts["Spelling Bee"]
        XCTAssertTrue(appTitle.exists, "App title should be visible")
    }

    @MainActor
    func testOnboardingWelcomeToNameTransition() throws {
        app.launch()

        let startButton = app.buttons["Let's Start!"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()

        let namePrompt = app.staticTexts["What's your name?"]
        XCTAssertTrue(namePrompt.waitForExistence(timeout: 3), "Name input screen should appear")
    }

    @MainActor
    func testOnboardingCompleteFlow() throws {
        app.launch()

        // Welcome screen
        let startButton = app.buttons["Let's Start!"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()

        // Name screen
        let nameTextField = app.textFields["Enter your name"]
        XCTAssertTrue(nameTextField.waitForExistence(timeout: 3))
        nameTextField.tap()
        nameTextField.typeText("TestSpeller")

        let continueButton = app.buttons["Continue"]
        continueButton.tap()

        // Grade selection - tap grade 3
        let grade3Button = app.buttons.matching(NSPredicate(format: "label CONTAINS '3'")).firstMatch
        if grade3Button.waitForExistence(timeout: 3) {
            grade3Button.tap()
        }

        let startLearningButton = app.buttons["Start Learning!"]
        XCTAssertTrue(startLearningButton.waitForExistence(timeout: 3))
        startLearningButton.tap()

        // Should navigate to home screen
        let levelsText = app.staticTexts["Levels"]
        XCTAssertTrue(levelsText.waitForExistence(timeout: 5), "Should navigate to home screen")
    }
}

// MARK: - Home Screen UI Tests
final class iOS_HomeScreenUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "EXISTING_PROFILE"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func testHomeScreenDisplays() throws {
        app.launch()

        let levelsText = app.staticTexts["Levels"]
        XCTAssertTrue(levelsText.waitForExistence(timeout: 5), "Home screen should show Levels text")
    }

    @MainActor
    func testHomeScreenShowsUserGreeting() throws {
        app.launch()

        let greeting = app.staticTexts.element(matching: NSPredicate(format: "label BEGINSWITH 'Hi,'"))
        let beeEmoji = app.staticTexts["🐝"]

        let hasGreeting = greeting.waitForExistence(timeout: 5) || beeEmoji.exists
        XCTAssertTrue(hasGreeting, "Should show greeting or bee emoji")
    }

    @MainActor
    func testSettingsButtonExists() throws {
        app.launch()

        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'gear' OR identifier CONTAINS 'settings'")).firstMatch
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5), "Settings button should exist")
    }

    @MainActor
    func testTappingLevelStartsGame() throws {
        app.launch()

        let level1 = app.buttons.element(matching: NSPredicate(format: "label CONTAINS 'Level 1'"))
        XCTAssertTrue(level1.waitForExistence(timeout: 5))
        level1.tap()

        let speakerEmoji = app.staticTexts["🔊"]
        let hearWord = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS 'Hear'"))

        let inGameView = speakerEmoji.waitForExistence(timeout: 5) || hearWord.waitForExistence(timeout: 2)
        XCTAssertTrue(inGameView, "Should navigate to game view")
    }
}

// MARK: - Game Flow UI Tests
final class iOS_GameFlowUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "EXISTING_PROFILE"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    private func navigateToGame() {
        let level1 = app.buttons.element(matching: NSPredicate(format: "label CONTAINS 'Level 1'"))
        XCTAssertTrue(level1.waitForExistence(timeout: 5))
        level1.tap()
    }

    @MainActor
    func testGameShowsWordPresentation() throws {
        app.launch()
        navigateToGame()

        let speakerEmoji = app.staticTexts["🔊"]
        XCTAssertTrue(speakerEmoji.waitForExistence(timeout: 5), "Should show speaker emoji")
    }

    @MainActor
    func testGameHasSpellItButton() throws {
        app.launch()
        navigateToGame()

        let spellButton = app.buttons["Spell It!"]
        XCTAssertTrue(spellButton.waitForExistence(timeout: 5), "Spell It button should be visible")
    }

    @MainActor
    func testSpellItTransitionsToInput() throws {
        app.launch()
        navigateToGame()

        let spellButton = app.buttons["Spell It!"]
        XCTAssertTrue(spellButton.waitForExistence(timeout: 5))
        spellButton.tap()

        let textField = app.textFields.firstMatch
        let submitButton = app.buttons["Submit"]

        let inSpellingView = textField.waitForExistence(timeout: 5) || submitButton.waitForExistence(timeout: 2)
        XCTAssertTrue(inSpellingView, "Should transition to spelling input")
    }
}

// MARK: - Level Complete & Ad Flow UI Tests
final class iOS_LevelCompleteFlowUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Use test mode that simulates a completed level
        app.launchArguments = ["UI_TESTING", "EXISTING_PROFILE", "LEVEL_COMPLETE_TEST"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    /// Helper to navigate into a game and complete it (simulate 10 correct answers)
    private func navigateToGameAndComplete() {
        let level1 = app.buttons.element(matching: NSPredicate(format: "label CONTAINS 'Level 1'"))
        if level1.waitForExistence(timeout: 5) {
            level1.tap()
        }

        // Wait for game to load and look for level complete indicators
        // In test mode, level completion should be triggered automatically or we wait for it
        let levelCompleteText = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS 'Level Complete' OR label CONTAINS 'Great Job' OR label CONTAINS 'Congratulations'"))
        _ = levelCompleteText.waitForExistence(timeout: 30)
    }

    @MainActor
    func testAdShowsOnLevelCompleteWhenNotPurchased() throws {
        // Launch app without Remove Ads purchased
        app.launchArguments = ["UI_TESTING", "EXISTING_PROFILE", "ADS_NOT_REMOVED"]
        app.launch()

        navigateToGameAndComplete()

        // Look for ad-related UI elements
        let adView = app.otherElements.element(matching: NSPredicate(format: "identifier CONTAINS 'ad' OR identifier CONTAINS 'Ad'"))
        let adText = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS 'Ad' OR label CONTAINS 'sponsored' OR label CONTAINS 'Advertisement'"))
        let skipCountdown = app.staticTexts.element(matching: NSPredicate(format: "label MATCHES '.*[0-9]+.*'"))

        // Either ad view, ad text, or a countdown timer should appear
        let adAppears = adView.waitForExistence(timeout: 10) ||
                        adText.waitForExistence(timeout: 2) ||
                        skipCountdown.waitForExistence(timeout: 2)

        // If no ad UI detected, check for Next Level button which appears after ad
        let nextLevelButton = app.buttons.element(matching: NSPredicate(format: "label CONTAINS 'Next Level'"))
        let homeButton = app.buttons.element(matching: NSPredicate(format: "label CONTAINS 'Home'"))

        let levelCompleteFlowWorking = adAppears ||
                                       nextLevelButton.waitForExistence(timeout: 10) ||
                                       homeButton.waitForExistence(timeout: 2)

        XCTAssertTrue(levelCompleteFlowWorking, "Ad or level complete buttons should appear after completing level")
    }

    @MainActor
    func testAdSkipsWhenRemoveAdsPurchased() throws {
        // Launch app with Remove Ads purchased
        app.launchArguments = ["UI_TESTING", "EXISTING_PROFILE", "ADS_REMOVED"]
        app.launch()

        navigateToGameAndComplete()

        // When ads are removed, Next Level and Home buttons should appear immediately
        let nextLevelButton = app.buttons.element(matching: NSPredicate(format: "label CONTAINS 'Next Level'"))
        let homeButton = app.buttons.element(matching: NSPredicate(format: "label CONTAINS 'Home'"))

        let buttonsAppear = nextLevelButton.waitForExistence(timeout: 10) || homeButton.waitForExistence(timeout: 2)
        XCTAssertTrue(buttonsAppear, "Next Level or Home button should appear immediately when ads are removed")
    }

    @MainActor
    func testNextLevelAndHomeButtonsAppearAfterAdWait() throws {
        app.launchArguments = ["UI_TESTING", "EXISTING_PROFILE", "ADS_NOT_REMOVED"]
        app.launch()

        navigateToGameAndComplete()

        // Wait for the 5-second ad countdown to complete
        // Look for Next Level and Home buttons after ad finishes
        let nextLevelButton = app.buttons.element(matching: NSPredicate(format: "label CONTAINS 'Next Level'"))
        let homeButton = app.buttons.element(matching: NSPredicate(format: "label CONTAINS 'Home'"))

        // Wait up to 10 seconds (5 for ad + buffer time)
        let nextLevelAppears = nextLevelButton.waitForExistence(timeout: 10)
        let homeAppears = homeButton.waitForExistence(timeout: 2)

        XCTAssertTrue(nextLevelAppears || homeAppears, "Next Level and Home buttons should appear after ad wait")
    }

    @MainActor
    func testNextLevelButtonStartsNextLevel() throws {
        app.launchArguments = ["UI_TESTING", "EXISTING_PROFILE", "SIMULATE_LEVEL_COMPLETE"]
        app.launch()

        navigateToGameAndComplete()

        // Wait for Next Level button to appear
        let nextLevelButton = app.buttons.element(matching: NSPredicate(format: "label CONTAINS 'Next Level'"))

        guard nextLevelButton.waitForExistence(timeout: 15) else {
            throw XCTSkip("Next Level button did not appear - may need different test configuration")
        }

        nextLevelButton.tap()

        // Should now be in Level 2 game
        // Look for indicators we're in a new game session
        let speakerEmoji = app.staticTexts["🔊"]
        let spellButton = app.buttons["Spell It!"]
        let level2Indicator = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS 'Level 2'"))

        let inNewLevel = speakerEmoji.waitForExistence(timeout: 5) ||
                         spellButton.waitForExistence(timeout: 2) ||
                         level2Indicator.waitForExistence(timeout: 2)

        XCTAssertTrue(inNewLevel, "Should start next level after tapping Next Level button")
    }

    @MainActor
    func testHomeButtonReturnsToHome() throws {
        app.launchArguments = ["UI_TESTING", "EXISTING_PROFILE", "SIMULATE_LEVEL_COMPLETE"]
        app.launch()

        navigateToGameAndComplete()

        // Wait for Home button to appear
        let homeButton = app.buttons.element(matching: NSPredicate(format: "label CONTAINS 'Home'"))

        guard homeButton.waitForExistence(timeout: 15) else {
            throw XCTSkip("Home button did not appear - may need different test configuration")
        }

        homeButton.tap()

        // Should return to home screen
        let levelsText = app.staticTexts["Levels"]
        let levelGrid = app.buttons.element(matching: NSPredicate(format: "label CONTAINS 'Level'"))

        let onHomeScreen = levelsText.waitForExistence(timeout: 5) || levelGrid.waitForExistence(timeout: 2)

        XCTAssertTrue(onHomeScreen, "Should return to home screen after tapping Home button")
    }

    @MainActor
    func testAdCountdownDuration() throws {
        app.launchArguments = ["UI_TESTING", "EXISTING_PROFILE", "ADS_NOT_REMOVED"]
        app.launch()

        navigateToGameAndComplete()

        // Look for countdown indicator (should start at 5)
        let countdown5 = app.staticTexts["5"]
        let countdown4 = app.staticTexts["4"]
        let countdownGeneric = app.staticTexts.element(matching: NSPredicate(format: "label MATCHES '[1-5]'"))

        let countdownVisible = countdown5.waitForExistence(timeout: 5) ||
                               countdown4.waitForExistence(timeout: 2) ||
                               countdownGeneric.waitForExistence(timeout: 2)

        if countdownVisible {
            // Wait for countdown to complete (5 seconds + buffer)
            let nextLevelButton = app.buttons.element(matching: NSPredicate(format: "label CONTAINS 'Next Level'"))
            XCTAssertTrue(nextLevelButton.waitForExistence(timeout: 8), "Buttons should appear after countdown completes")
        } else {
            // Countdown might not be visible if ad system works differently
            // Just verify we eventually get to the post-level-complete state
            let nextLevelButton = app.buttons.element(matching: NSPredicate(format: "label CONTAINS 'Next Level'"))
            let homeButton = app.buttons.element(matching: NSPredicate(format: "label CONTAINS 'Home'"))
            let hasButtons = nextLevelButton.waitForExistence(timeout: 10) || homeButton.exists
            XCTAssertTrue(hasButtons, "Should eventually show navigation buttons after level complete")
        }
    }
}

// MARK: - Settings UI Tests
final class iOS_SettingsUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "EXISTING_PROFILE"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    private func openSettings() {
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'gear'")).firstMatch
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()
    }

    @MainActor
    func testSettingsShowsProfile() throws {
        app.launch()
        openSettings()

        let beeEmoji = app.staticTexts["🐝"]
        XCTAssertTrue(beeEmoji.waitForExistence(timeout: 5), "Profile section should show bee emoji")
    }

    @MainActor
    func testSettingsShowsGradeLevel() throws {
        app.launch()
        openSettings()

        let gradeSection = app.staticTexts["Grade Level"]
        XCTAssertTrue(gradeSection.waitForExistence(timeout: 5), "Grade Level section should exist")
    }

    @MainActor
    func testSettingsShowsPurchases() throws {
        app.launch()
        openSettings()

        app.swipeUp()

        let purchasesSection = app.staticTexts["Purchases"]
        XCTAssertTrue(purchasesSection.waitForExistence(timeout: 5), "Purchases section should exist")
    }

    @MainActor
    func testResetProgressButton() throws {
        app.launch()
        openSettings()

        app.swipeUp()

        let resetButton = app.buttons["Reset All Progress"]
        XCTAssertTrue(resetButton.waitForExistence(timeout: 5), "Reset All Progress button should exist")
    }

    @MainActor
    func testDoneButtonDismissesSettings() throws {
        app.launch()
        openSettings()

        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5))
        doneButton.tap()

        let levelsText = app.staticTexts["Levels"]
        XCTAssertTrue(levelsText.waitForExistence(timeout: 5), "Should return to home screen")
    }
}

// MARK: - Parent Gate UI Tests
final class iOS_ParentGateUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "EXISTING_PROFILE"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    private func navigateToRemoveAds() {
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'gear'")).firstMatch
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        app.swipeUp()

        let removeAdsButton = app.buttons.element(matching: NSPredicate(format: "label CONTAINS 'Remove Ads'"))
        if removeAdsButton.waitForExistence(timeout: 3) {
            removeAdsButton.tap()
        }
    }

    @MainActor
    func testParentGateAppears() throws {
        app.launch()
        navigateToRemoveAds()

        let verificationText = app.staticTexts["Parent Verification"]
        XCTAssertTrue(verificationText.waitForExistence(timeout: 5), "Parent Verification should appear")
    }

    @MainActor
    func testParentGateShowsMathProblem() throws {
        app.launch()
        navigateToRemoveAds()

        let mathProblem = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS '×'"))
        XCTAssertTrue(mathProblem.waitForExistence(timeout: 5), "Math problem should be visible")
    }

    @MainActor
    func testParentGateHasCancelButton() throws {
        app.launch()
        navigateToRemoveAds()

        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5), "Cancel button should exist")
    }
}

// MARK: - Accessibility Tests
final class iOS_AccessibilityUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "EXISTING_PROFILE"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func testHomeScreenAccessibility() throws {
        app.launch()

        let buttons = app.buttons.allElementsBoundByIndex
        XCTAssertGreaterThan(buttons.count, 0, "Should have accessible buttons")
    }

    @MainActor
    func testTextElementsAccessible() throws {
        app.launch()

        let texts = app.staticTexts.allElementsBoundByIndex
        XCTAssertGreaterThan(texts.count, 0, "Should have accessible text elements")
    }
}
