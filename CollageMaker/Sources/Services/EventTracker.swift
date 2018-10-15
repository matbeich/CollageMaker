//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Crashlytics
import Utils

struct Event {
    var name: String
    var parameters: [String: String]

    init(name: String, parameters: [String: String] = [:]) {
        self.name = name
        self.parameters = parameters
    }
}

final class EventTracker {
    static let shared = EventTracker()

    func track(_ event: Event) {
        if Environment.isDebug {
            print("Event tracked { name: \(event.name), params: \(event.parameters) }")
        }

        Answers.logCustomEvent(withName: event.name, customAttributes: event.parameters)
    }
}

extension Event {
    static func share(destination: ShareDestination) -> Event {
        return Event(
            name: "Sharing",
            parameters: ["Destination": destination.rawValue]
        )
    }

    static func shake() -> Event {
        return Event(name: "Shaking")
    }

    static func split(by axis: Axis) -> Event {
        return Event(name: "Split", parameters: ["Axis": axis.rawValue])
    }
}
