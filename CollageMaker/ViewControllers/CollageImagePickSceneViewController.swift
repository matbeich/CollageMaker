//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit
import Photos
import SnapKit

protocol CollageImagePickSceneViewControllerDelegate: AnyObject {
    func collageImagePickSceneViewControllerTemplateBar(with selectedAssets: [PHAsset], didSelectTemplate: Collage)
}

class CollageImagePickSceneViewController: UIViewController {
    
    weak var delegate: CollageImagePickSceneViewControllerDelegate?
    
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
        templateController.delegate = self
    }
    
    private func showTemplateController() {
        templateControllerContainer.center.y = view.bounds.height - templateControllerContainer.bounds.size.height / 2
    }
    
    private func makeConstraints() {
        templateControllerContainer.bounds.size = CGSize(width: view.bounds.width, height: view.bounds.height / 3.5)
        templateControllerContainer.center = CGPoint(x: view.center.x, y: view.frame.maxY + templateControllerContainer.bounds.size.height / 2 - 50)
    }
    
    private var selectedAssets: [PHAsset] = []
    private let templateControllerContainer = TemplateControllerView(frame: .zero, headerText: "Choose template")
    private var mainController: ImagePickerCollectionViewController
    private var templateController = TemplateBarCollectionViewController(templates: [])
}

extension CollageImagePickSceneViewController: ImagePickerCollectionViewControllerDelegate {
    func imagePickerCollectionViewController(_ controller: ImagePickerCollectionViewController, didSelect assets: [PHAsset]) {
        selectedAssets = assets
  
        CollageTemplateProvider.templates(for: selectedAssets) { [weak self] templates in
            if let templates = templates, !templates.isEmpty {
                UIView.animate(withDuration: 0.2, animations: { self?.showTemplateController() }) { _ in
                    self?.templateController.templates = templates
                }
            } else {
                UIView.animate(withDuration: 0.2, animations: { self?.makeConstraints() }) { _ in self?.templateController.templates = [] }
            }
        }
    }
}

extension CollageImagePickSceneViewController: TemplateBarCollectionViewControllerDelegate {
    func templateBarCollectionViewController(_ controller: TemplateBarCollectionViewController, didSelect collage: Collage) {
        PhotoLibraryService.cacheImages(for: selectedAssets)
        
        CollageTemplateProvider.highQualityCollage(from: collage, assets: selectedAssets) { [weak self] collage in
            if let selectedAssets = self?.selectedAssets, let sself = self {
                sself.delegate?.collageImagePickSceneViewControllerTemplateBar(with: selectedAssets, didSelectTemplate: collage)
            }
        }
    }
}
