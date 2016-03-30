public func hasProperty<T, U>(propertyMatcher: Matcher<String>, matcher: Matcher<U>) -> Matcher<T> {
    return Matcher("has property \(propertyMatcher.description) with value \(matcher.description)") {
        (value: T) -> MatchResult in
        if let propertyValue = getProperty(value, keyMatcher: propertyMatcher) {
            if propertyValue is U {
                return delegateMatching(propertyValue as! U, matcher: matcher) {
                    return "property value " + describeActualValue(propertyValue, mismatchDescription: $0)
                }
            } else {
                return .Mismatch("incompatible property type")
            }
        } else {
            return .Mismatch("missing property")
        }
    }
}

public func hasProperty<T, U: Equatable>(propertyName: String, expectedValue: U) -> Matcher<T> {
    return hasProperty(equalToWithoutDescription(propertyName), matcher: equalToWithoutDescription(expectedValue))
}

public func hasProperty<T, U>(propertyName: String, matcher: Matcher<U>) -> Matcher<T> {
    return hasProperty(equalToWithoutDescription(propertyName), matcher: matcher)
}

private func getProperty<T>(value: T, keyMatcher: Matcher<String>) -> Any? {
    let mirror = Mirror(reflecting: value)
    for child in mirror.children {
        let (thisPropertyName, thisProperty) = child
        if keyMatcher.matches(thisPropertyName!) {
            return (thisProperty as! Mirror.Child).value
        }
    }
    return nil
}
