//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit


extension UIBarButtonItem {
    static func collageCamera(action: Selector, target: Any?) -> UIBarButtonItem {
        return UIBarButtonItem(image: R.image.camera_btn(), style: UIBarButtonItemStyle.plain, target: target, action: action)
    }
    
    static func collageShare(action: Selector, target: Any?) -> UIBarButtonItem {
        return UIBarButtonItem(image: R.image.share_btn(), style: UIBarButtonItemStyle.plain, target: target, action: action)
    }
}
