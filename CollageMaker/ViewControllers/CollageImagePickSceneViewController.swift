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
        view.addSubview(templateControllerContainer)
        
        navigationItem.title = "All Photos"
        navigationItem.hidesBackButton = true
        
        makeConstraints()
        addChild(templateController, to: templateControllerContainer.templateContainerView)
    }
    
    private func showTemplateController() {
        templateControllerContainer.center.y = view.bounds.height - templateControllerContainer.bounds.size.height / 2
    }
    
    private func makeConstraints() {
        templateControllerContainer.bounds.size = CGSize(width: view.bounds.width, height: view.bounds.height / 3.5)
        templateControllerContainer.center = CGPoint(x: view.center.x, y: view.frame.maxY + templateControllerContainer.bounds.size.height / 2 - 50)
    }
    
    private let templateControllerContainer = TemplateControllerView()
    private var mainController: ImagePickerCollectionViewController
    private var templateController = TemplateBarCollectionViewController(templates: [])
}

extension CollageImagePickSceneViewController: ImagePickerCollectionViewControllerDelegate {
    func imagePickerCollectionViewController(_ controller: ImagePickerCollectionViewController, didSelect assets: [PHAsset]) {
        
        CollageTemplateProvider.collage(for: assets) { [weak self] collage in
            if let collage = collage {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.showTemplateController()
                }) { _ in
                    self?.templateController.templates = [collage, collage, collage, collage, collage, collage, collage]
                }
            } else {
                UIView.animate(withDuration: 0.2, animations: { self?.makeConstraints() }) { _ in self?.templateController.templates = [] }
            }
        }
    }
}
