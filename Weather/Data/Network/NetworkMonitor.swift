import Foundation
import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    private(set) var isConnected: Bool = true
    private(set) var connectionType: NWInterface.InterfaceType?

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            self?.connectionType = [.wifi, .cellular, .wiredEthernet, .loopback, .other]
                .first(where: { path.usesInterfaceType($0) })
        }

        monitor.start(queue: queue)
    }
}
