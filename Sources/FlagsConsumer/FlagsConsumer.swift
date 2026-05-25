import Foundation
import FlagsIOS

/// Thin public wrapper so an external app can depend on `FlagsConsumer` and still exercise `FlagsIOS` APIs.
public enum FlagsConsumer {

    public static func greeting() -> String {
        let v = FlagsIOSVersion.current
        let t = FlagsStringUtils.trimmed("  hello  ")
        return "FlagsIOS \(v) says \(t)"
    }

    public static func isNonEmpty(_ s: String?) -> Bool {
        guard let s = s else { return false }
        return FlagsStringUtils.nonEmptyTrimmed(s) != nil
    }
}
