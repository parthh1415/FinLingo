import Foundation

/// Compact money formatting for an idle game where balances reach billions/trillions.
/// Also avoids `Int(Double)` traps on astronomically large values.
enum CurrencyFormat {
    /// e.g. 950 → "$950", 12_500 → "$12.5K", 3_200_000 → "$3.2M", 4.1e9 → "$4.10B".
    static func short(_ value: Double) -> String {
        guard value.isFinite else { return "$0" } // never render "$nanQ" if something upstream breaks
        let v = max(value, 0)
        switch v {
        case ..<1_000:                 return "$\(Int(v))"
        case ..<1_000_000:             return String(format: "$%.1fK", v / 1_000)
        case ..<1_000_000_000:         return String(format: "$%.2fM", v / 1_000_000)
        case ..<1_000_000_000_000:     return String(format: "$%.2fB", v / 1_000_000_000)
        case ..<1_000_000_000_000_000: return String(format: "$%.2fT", v / 1_000_000_000_000)
        default:                       return String(format: "$%.2fQ", v / 1_000_000_000_000_000)
        }
    }

    static func short(_ value: Int) -> String { short(Double(value)) }

    /// Like `short`, but keeps the sign — for net worth, which can go negative when debt
    /// outweighs assets. e.g. -2_500 → "-$2.5K".
    static func signed(_ value: Double) -> String {
        guard value.isFinite else { return "$0" }
        return value < 0 ? "-" + short(-value) : short(value)
    }

    /// Compact rate without the `$` prefix logic duplicated — e.g. "$3.2M/s".
    static func perSecond(_ value: Double) -> String { short(value) + "/s" }
}

/// Compact formatting for compute/sec (no currency symbol).
enum NumberFormatShort {
    static func short(_ value: Double) -> String {
        guard value.isFinite else { return "0" }
        let v = max(value, 0)
        switch v {
        case ..<1_000:                 return "\(Int(v))"
        case ..<1_000_000:             return String(format: "%.1fK", v / 1_000)
        case ..<1_000_000_000:         return String(format: "%.2fM", v / 1_000_000)
        case ..<1_000_000_000_000:     return String(format: "%.2fB", v / 1_000_000_000)
        default:                       return String(format: "%.2fT", v / 1_000_000_000_000)
        }
    }
}
