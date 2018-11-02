//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation
import Utils

final class EventProperty<Something> {
    public typealias ObserverAction = (Something) -> Void

    var value: Something {
        didSet {
            synchronized(self) {
                signal.publicize(value)
            }
        }
    }

    init(value: Something) {
        self.value = value
    }

    func subscribe(on queue: DispatchQueue? = nil, with callback: @escaping ObserverAction) {
        signal.subscribe(on: queue) { value in
            callback(value)
        }
    }

    private let signal = Signal<Something>()
}
