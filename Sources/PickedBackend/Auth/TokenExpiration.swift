
import Foundation

//MARK: Enumerado de tiempos de expiración del token por si queremos hacer pruebas
enum TokenExpiration {
    static let thirtyDays: TimeInterval = 60 * 60 * 24 * 30
    static let fiveMinutes: TimeInterval = 60 * 10
    static let sevenDays: TimeInterval = 60 * 60 * 24 * 7
    static let oneDay: TimeInterval = 60 * 60 * 24
}
