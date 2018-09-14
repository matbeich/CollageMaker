//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit
import Photos
import SnapKit

class CollageImagePickSceneViewController: UIViewController {
    
    init(main: ImagePickerCollectionViewController) {
        mainController = main
        
        super.init(nibName: nil, bundle: nil)
        mainController.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(mainController, to: view)
        showTemplateController()
    }
    
    func showTemplateController() {
        view.addSubview(templateControllerContainer)
        
        makeConstraints()
        addChild(templateController, to: templateControllerContainer)
    }
    
    private func makeConstraints() {
        templateControllerContainer.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().dividedBy(3.5)
        }
    }
    
    private var mainController: ImagePickerCollectionViewController
    private var templateController: TemplateBarCollectionViewController?
    private let templateControllerContainer = UIView()
}

extension CollageImagePickSceneViewController: ImagePickerCollectionViewControllerDelegate {
    func imagePickerCollectionViewController(_ controller: ImagePickerCollectionViewController, didSelect assets: [PHAsset]) {
        print(assets)
    }
}
