//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import XCTest
import FBSnapshotTestCase
import Photos
@testable import CollageMaker

class TemplateBarCollectionViewCellTestCase: FBSnapshotTestCase {
    
    var cell: TemplateBarCollectionViewCell!
    var collageTemplateProvider: CollageTemplateProvider!
    
    override func setUp() {
        super.setUp()
        recordMode = true
        
        collageTemplateProvider = CollageTemplateProvider(photoLibrary: MockPhotoLibrary())
        cell = TemplateBarCollectionViewCell(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 300)), collageTemplateProvider: collageTemplateProvider)
        cell.layoutIfNeeded()
    }
    
    override func tearDown() {
        cell = nil
        super.tearDown()
    }
    
    func test() {
        let assets = (0..<3).map { _ in PHAsset() }
        let template = collageTemplateProvider.templates(for: assets).first
        cell.collageTemplate = template
        cell.update(synchronously: true)
        FBSnapshotVerifyView(cell)
    }
}
