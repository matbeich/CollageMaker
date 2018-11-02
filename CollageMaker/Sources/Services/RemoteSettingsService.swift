//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import FirebaseRemoteConfig
import UIKit

final class RemoteSettingsService {
    var cellsCount: Int {
        return remoteEvent.value.numberOfCells
    }

    static let shared = RemoteSettingsService(remoteConfig: .remoteConfig(), remoteEvent: EventProperty(value: .default))

    init(remoteConfig: RemoteConfig, remoteEvent: EventProperty<Config>) {
        self.config = remoteConfig
        self.remoteEvent = remoteEvent
        config.configSettings = RemoteConfigSettings(developerModeEnabled: true)

        setup()
    }

    func subscribe(on queue: DispatchQueue? = nil, with callback: @escaping (Config) -> Void) {
        remoteEvent.subscribe(on: queue, with: callback)
    }

    func fetchRemoteSettings() {
        config.fetch(withExpirationDuration: 70) { [weak self] status, error in
            guard let `self` = self else {
                return
            }

            if status == .success {
                self.config.activateFetched()
                self.remoteEvent.value = self.constructConfig()
            }
        }
    }

    private func setup() {
        fetchRemoteSettings()
        setUpdateTimer(with: 70)
    }

    private func setUpdateTimer(with timeInterval: TimeInterval) {
        DispatchQueue.global().asyncAfter(deadline: .now() + timeInterval) { [weak self] in
            self?.fetchRemoteSettings()
            self?.setUpdateTimer(with: timeInterval)
        }
    }

    private func constructConfig() -> Config {
        return Config(numberOfCells: config.configValue(forKey: Constants.Key.numberOfCells).numberValue?.intValue ?? 9)
    }

    private var config: RemoteConfig
    private let remoteEvent: EventProperty<Config>
}

struct Constants {
    struct Key {
        static let numberOfCells = "number_of_cells"
    }
}
