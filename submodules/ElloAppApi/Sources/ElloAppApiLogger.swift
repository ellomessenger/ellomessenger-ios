import Foundation

private var elloappApiLogger: (String) -> Void = { _ in }

public func setElloAppApiLogger(_ f: @escaping (String) -> Void) {
    elloappApiLogger = f
}

func elloappApiLog(_ what: @autoclosure () -> String) {
    elloappApiLogger(what())
}
