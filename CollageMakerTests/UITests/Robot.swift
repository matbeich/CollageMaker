//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import EarlGrey
import Foundation

protocol Robot {}

protocol RobotElement {
    var id: String { get }
    var greyInteraction: GREYInteraction { get }
}

extension RobotElement {
    var greyInteraction: GREYInteraction {
        return EarlGrey.selectElement(with: grey_accessibilityID(id))
    }
}

extension Robot {
    @discardableResult
    func tap(_ element: RobotElement) -> Self {
        element.greyInteraction.perform(grey_tap())

        return self
    }

    @discardableResult
    func expect(_ element: RobotElement, isVisible: Bool) -> Self {
        let matcher = isVisible ? grey_sufficientlyVisible() : grey_notVisible()
        element.greyInteraction.assert(matcher)

        return self
    }
}
