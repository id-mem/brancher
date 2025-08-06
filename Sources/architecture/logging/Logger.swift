import Foundation

struct Logger {
    private static let resetColor = "\u{001B}[0;39m"
    private static let infoColor = "\u{001B}[0;34m"
    private static let successColor = "\u{001B}[0;32m"
    private static let errorColor = "\u{001B}[0;31m"
    private static let timestampColor = "\u{001B}[0;96m"
    private static let nameMainColor = "\u{001B}[0;35m"
    private static let nameAltColor = "\u{001B}[0;93m"

    static func startup(file configurationSource: String) {
        print()
        print(
            """
             \(nameMainColor)______   ______ _______ __   _ _______ _     _ _____ __   _  ______       \(nameAltColor)_____
             \(nameMainColor)|_____] |_____/ |_____| | \\  | |       |_____|   |   | \\  | |  ____   \(nameMainColor)__\(nameAltColor)/\(nameMainColor)___
             \(nameMainColor)|_____] |    \\_ |     | |  \\_| |_____  |     | __|__ |  \\_| |_____|        \(nameAltColor)\\_____
            """
        )
        print(
            "\(nameAltColor)====================================================================="
        )
    }

    static func messageWithTimestamp(_ message: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeStamp: String = "[\(dateFormatter.string(from: Date()))] - "

        guard !message.isEmpty else { return }

        print("\(timestampColor)\(timeStamp) \(message)")
    }

    static func logInfo(_ message: String) {
        messageWithTimestamp("\(infoColor)Info: \(resetColor)\(message)")
    }

    static func logSuccess(_ message: String) {
        messageWithTimestamp("\(successColor)Success: \(resetColor)\(message)")
    }

    static func logGeneralError(_ message: String) {
        messageWithTimestamp("\(errorColor)Error: \(resetColor)\(message)")
    }

    static func logAutomationError(_ error: AutomationError) {
        messageWithTimestamp("\(errorColor)Error: \(resetColor)\(error.localizedDescription)")
    }
}
