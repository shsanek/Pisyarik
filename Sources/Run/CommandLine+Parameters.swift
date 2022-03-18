import Foundation

extension CommandLine {
    struct ParameterItem {
        let key: String?
        let value: String?
    }
    
    static var parameters: [ParameterItem] {
        var i = 0
        var lastValue: String?
        var result = [ParameterItem]()
        while i < CommandLine.arguments.count {
            var key = CommandLine.arguments[i]
            if key.hasPrefix("-") {
                lastValue.flatMap {
                    result.append(.init(key: $0, value: nil))
                }
                key.removeFirst(1)
                lastValue = key
            } else {
                result.append(.init(key: lastValue, value: key))
                lastValue = nil
            }
            i += 1
        }
        lastValue.flatMap {
            result.append(.init(key: $0, value: nil))
        }
        return result
    }
}

extension Array where Element == CommandLine.ParameterItem {
    func first(_ key: String) -> CommandLine.ParameterItem? {
        first(where: { $0.key == key })
    }
    
    func value(_ key: String) -> String? {
        first(where: { $0.key == key })?.value
    }
    
    func has(_ key: String) -> Bool {
        contains(where: { $0.key == key })
    }
}
