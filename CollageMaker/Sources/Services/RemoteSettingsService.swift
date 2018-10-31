//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import FirebaseRemoteConfig
import Foundation

final class RemoteSettingsService {
    var numberOfCells: Int {
        return config.configValue(forKey: Constants.Key.numberOfCells).numberValue?.intValue ?? 0
    }

    static let shared = RemoteSettingsService(remoteConfig: .remoteConfig(), defaultConfig: .default)

    init(remoteConfig: RemoteConfig, defaultConfig: Config) {
        self.config = remoteConfig
        self.defaultConfig = defaultConfig

        applyDefaultSettings() // FIXME: apply only at first start
        applyRemoteSettings()
    }

    func applyRemoteSettings() {
        config.fetch { [weak self] status, error in
            guard let `self` = self else {
                return
            }

            if status == .success { self.config.activateFetched() }
        }
    }

    func applyDefaultSettings() {
        config.setDefaults(defaultConfig.values)
    }

    private let config: RemoteConfig
    private(set) var defaultConfig: Config
}

struct Config {
    let values: [String: NSObject]

    init(numberOfCells: Int) {
        self.values = [Constants.Key.numberOfCells: NSNumber(value: numberOfCells)]
    }
}

extension Config {
    static let `default` = Config(numberOfCells: 9)
}

struct Constants {
    struct Key {
        static let numberOfCells = "number_of_cells"
    }
}
