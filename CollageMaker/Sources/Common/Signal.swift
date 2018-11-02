//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation
import Utils

final class Signal<Something> {
    public typealias ObserverAction = (Something) -> Void

    func publicize(_ value: Something) {
        observers.values.forEach { $0.notify(with: value) }
    }

    func subscribe(on queue: DispatchQueue? = nil, with callback: @escaping ObserverAction) {
        let id = UUID()

        synchronized(self) {
            observers[id] = Observer(action: callback, queue: queue)
        }
    }

    private var observers: [UUID: Observer] = [:]

    final class Observer {
        let actionWith: ObserverAction
        let queue: DispatchQueue?

        init(action: @escaping ObserverAction, queue: DispatchQueue? = nil) {
            self.actionWith = action
            self.queue = queue
        }

        func notify(with value: Something) {
            if let queue = queue {
                queue.async { [weak self] in
                    self?.actionWith(value)
                }

                return
            }

            actionWith(value)
        }
    }
}
