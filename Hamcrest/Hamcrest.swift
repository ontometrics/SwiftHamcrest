import Foundation
import Swift
import XCTest

/// Reporter function that is called whenever a Hamcrest assertion fails.
/// By default this calls XCTFail, except in Playgrounds where it does nothing.
/// This is intended for testing Hamcrest itself.
public var HamcrestReportFunction: (_: String, file: StaticString, line: UInt) -> () = HamcrestDefaultReportFunction
public let HamcrestDefaultReportFunction =
    isPlayground()
        ? {(message, file, line) in}
        : {(message, file, line) in XCTFail(message, file: file, line: line)}

// MARK: helpers

func filterNotNil<T>(array: [T?]) -> [T] {
    return array.filter({$0 != nil}).map({$0!})
}

func delegateMatching<T>(value: T, matcher: Matcher<T>, mismatchDescriber: String? -> String?) -> MatchResult {
    switch matcher.matches(value) {
    case .Match:
        return .Match
    case let .Mismatch(mismatchDescription):
        return .Mismatch(mismatchDescriber(mismatchDescription))
    }
}

func equalToWithoutDescription<T: Equatable>(expectedValue: T) -> Matcher<T> {
    return describedAs(describe(expectedValue), matcher: equalTo(expectedValue))
}

func isPlayground() -> Bool {
    let bundleIdentifier: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleIdentifier"]
    return (bundleIdentifier as? String)?.hasPrefix("com.apple.dt.playground.stub") ?? false
}

// MARK: assertThat

public func assertThat<T>(value: T, matcher: Matcher<T>,
                          file: StaticString = #file, line: UInt = #line) -> String {
    return reportResult(applyMatcher(matcher, toValue: value), file: file, line: line)
}

func applyMatcher<T>(matcher: Matcher<T>, toValue: T) -> String? {
    let match = matcher.matches(toValue)
    switch match {
    case .Match:
        return nil
    case let .Mismatch(mismatchDescription):
        return describeMismatch(toValue, description: matcher.description, mismatchDescription: mismatchDescription)
    }
}

func reportResult(possibleResult: String?, file: StaticString = #file, line: UInt = #line)
    -> String {

    if let result = possibleResult {
        HamcrestReportFunction(result, file: file, line: line)
        return result
    } else {
        // The return value is just intended for Playgrounds.
        return "👍"
    }
}
