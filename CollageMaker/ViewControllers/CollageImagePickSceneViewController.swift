//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit
import Photos
import SnapKit

protocol CollageImagePickSceneViewControllerDelegate: AnyObject {
    func collageImagePickSceneViewController(_ controller: CollageImagePickSceneViewController, templateBar: TemplateBarCollectionViewController, didSelectTemplate: Collage)
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
        navigationItem.leftBarButtonItem = UIBarButtonItem.collageCamera(action: #selector(openCamera), target: self)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: gradientButton)
        
        makeConstraints()
        addChild(templateController, to: templateControllerContainer.templateContainerView)
        templateController.delegate = self
    }
    
    @objc private func openCamera() {
        
    }
    
    private func showTemplateController() {
        templateControllerContainer.center.y = view.bounds.height - templateControllerContainer.bounds.size.height / 2
    }
    
    private func makeConstraints() {
        templateControllerContainer.bounds.size = CGSize(width: view.bounds.width, height: view.bounds.height / 3.5)
        templateControllerContainer.center = CGPoint(x: view.center.x, y: view.frame.maxY + templateControllerContainer.bounds.size.height / 2 - 50)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var selectedAssets: [PHAsset] = [] {
        willSet {
            PhotoLibraryService.stopCaching()
        } didSet {
            PhotoLibraryService.cacheImages(for: self.selectedAssets)
            gradientButton.setTitle(String(selectedAssets.count), for: .normal)
        }
    }
    
    private let gradientButton: GradientButton = {
        let button = GradientButton(type: .system)
        button.setTitle("0", for: .normal)
        button.showShadow = false
        button.titleLabel?.font = R.font.sfProTextBold(size: 16)
        
        return button
    }()
    
    private let templateControllerContainer = TemplateControllerView(frame: .zero, headerText: "Choose template")
    private var mainController: ImagePickerCollectionViewController
    private var templateController = TemplateBarCollectionViewController(templates: [])
}

extension CollageImagePickSceneViewController: ImagePickerCollectionViewControllerDelegate {
    func imagePickerCollectionViewController(_ controller: ImagePickerCollectionViewController, didSelect assets: [PHAsset]) {
        selectedAssets = assets
        
        let templates = CollageTemplateProvider.templates(for: selectedAssets.count, assets: selectedAssets)
        
        if !templates.isEmpty {
            UIView.animate(withDuration: 0.2, animations: { self.showTemplateController() }) { _ in
                self.templateController.templates = templates
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: { self.makeConstraints() }) { _ in self.templateController.templates = [] }
        }
    }
}

extension CollageImagePickSceneViewController: TemplateBarCollectionViewControllerDelegate {
    func templateBarCollectionViewController(_ controller: TemplateBarCollectionViewController, didSelect collageTemplate: CollageTemplate) {
        
        CollageTemplateProvider.collage(from: collageTemplate, size: .large) { [weak self] collage in
            if let sself = self {
                sself.delegate?.collageImagePickSceneViewController(sself, templateBar: controller, didSelectTemplate: collage)
            }
        }
    }
}
