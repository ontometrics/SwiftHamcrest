public func hasEntry<K: Hashable, V>(keyMatcher: Matcher<K>, valueMatcher: Matcher<V>)
    -> Matcher<Dictionary<K, V>> {

        return Matcher("a dictionary containing [\(keyMatcher.description) -> \(valueMatcher.description)]") {
            (dictionary: Dictionary<K, V>) -> Bool in

            for (key, value) in dictionary {
                if keyMatcher.matches(key) && valueMatcher.matches(value) {
                    return true
                }
            }
            return false
        }
}

public func hasEntry<K: Equatable, V: Equatable where K: Hashable>(expectedKey: K, expectedValue: V)
    -> Matcher<Dictionary<K, V>> {

        return hasEntry(equalToWithoutDescription(expectedKey), valueMatcher: equalToWithoutDescription(expectedValue))
}

public func hasKey<K: Hashable, V>(matcher: Matcher<K>) -> Matcher<Dictionary<K, V>> {
    return hasEntry(matcher, valueMatcher: anything())
}

public func hasKey<K, V where K: Equatable, K: Hashable>(expectedKey: K)
    -> Matcher<Dictionary<K, V>> {

        return hasKey(equalToWithoutDescription(expectedKey))
}

public func hasValue<K: Hashable, V>(matcher: Matcher<V>) -> Matcher<Dictionary<K, V>> {
    return hasEntry(anything(), valueMatcher: matcher)
}

public func hasValue<K: Hashable, V: Equatable>(expectedValue: V) -> Matcher<Dictionary<K, V>> {
    return hasValue(equalToWithoutDescription(expectedValue))
}
