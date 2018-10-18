//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Utils

struct Accessibility {
    enum View {
        case imagePickerCell(id: Int)
        case imageCollectionView
        case templateCollectionView
        case templateView
        case templateCell(id: Int)
        case collageView

        var value: String {
            switch self {
            case let .imagePickerCell(id: id): return "image_picker_cell.\(id)"
            case .imageCollectionView: return "image_collection_view"
            case .templateCollectionView: return "template_collection_view"
            case .templateView: return "template_view"
            case let .templateCell(id: id): return "teplate_cell.\(id)"
            case .collageView: return "collage_view"
            }
        }

        var id: String {
            return "com.dimasno1.view.\(value)"
        }
    }
}
