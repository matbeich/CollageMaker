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
        case shareFooter

        var value: String {
            switch self {
            case let .imagePickerCell(id: id): return "image_picker_cell.\(id)"
            case .imageCollectionView: return "image_collection_view"
            case .templateCollectionView: return "template_collection_view"
            case .templateView: return "template_view"
            case let .templateCell(id: id): return "teplate_cell.\(id)"
            case .collageView: return "collage_view"
            case .shareFooter: return "share_footer"
            }
        }

        var id: String {
            return "com.dimasno1.view.\(value)"
        }
    }

    enum NavigationControl {
        case back
        case share
        case select
        case close
        case camera

        var value: String {
            switch self {
            case .back: return "back_button"
            case .share: return "share_button"
            case .select: return "select_button"
            case .close: return "close_button"
            case .camera: return "camera_button"
            }
        }

        var id: String {
            return "com.dimasno1.navigationControl.\(value)"
        }
    }

    enum Button {
        case deleteButton
        case horizontalButton
        case verticalButton
        case addImageButton

        var value: String {
            switch self {
            case .horizontalButton: return "split_horizontal_button"
            case .verticalButton: return "split_vertical_button"
            case .addImageButton: return "add_image_button"
            case .deleteButton: return "delete_button"
            }
        }

        var id: String {
            return "com.dimasno1.button.\(value)"
        }
    }
}
