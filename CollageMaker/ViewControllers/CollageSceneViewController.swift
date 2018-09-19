//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit
import SnapKit
import AVKit


protocol CollageSceneViewControllerDelegate: AnyObject {
    func collageSceneViewController(_ controller: CollageSceneViewController, wantsToShare collage: Collage)
}

class CollageSceneViewController: UIViewController {
    
    weak var delegate: CollageSceneViewControllerDelegate?
    
    init(collage: Collage = Collage(), templates: [CollageTemplate]) {
        self.templates = templates
        
        super.init(nibName: nil, bundle: nil)
        collageViewController.collage = collage
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(collageViewContainer)
        view.addSubview(templateControllerView)
        view.addSubview(toolsBar)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.collageCamera(action: #selector(tryToTakePhoto), target: self)
        navigationItem.rightBarButtonItem = UIBarButtonItem.collageShare(action: #selector(shareCollage), target: self)
        navigationItem.title = "Edit"
        
        makeConstraints()
        
        toolsBar.delegate = self
        templateBarController.delegate = self
        templateBarController.templates = templates
        collageViewController.delegate = self
        
        addChild(collageViewController, to: collageViewContainer)
        addChild(templateBarController, to: templateControllerView)
    }
    
    private func makeConstraints() {
        collageViewContainer.snp.makeConstraints { make in
            if #available(iOS 11, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }
            
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(collageViewContainer.snp.width)
        }
        
        toolsBar.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(collageViewContainer).dividedBy(6)
        }
        
        templateControllerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(toolsBar.snp.top)
            make.top.equalTo(collageViewContainer.snp.bottom)
        }
    }
    
    @objc private func resetCollage() {
        collageViewController.resetCollage()
    }
    
    @objc private func shareCollage() {
        collageViewController.saveCellsVisibleRect()
        delegate?.collageSceneViewController(self, wantsToShare: collageViewController.collage)
    }
    
    func pickImage(camera: Bool = false) {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = camera && UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func tryToTakePhoto() {
        handle(cameraAuthService.status)
    }
    
    private func handle(_ avAuthorizationStatus: AVAuthorizationStatus) {
        if cameraAuthService.isAuthorized {
            pickImage(camera: true)
            return
        }
        
        switch avAuthorizationStatus {
        case .notDetermined: cameraAuthService.reqestAuthorization { self.handle($0) }
        case .denied: present(Alerts.cameraAccessDenied(), animated: true, completion: nil)
        case .restricted: present(Alerts.cameraAccessRestricted(), animated: true, completion: nil)
        default: break
        }
    }
    
    private let collageViewContainer: UIView = {
        let view = UIView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private var templates = [CollageTemplate]()
    private var collageViewController = CollageViewController()
    private let toolsBar = CollageToolbar.standart
    private let cameraAuthService = CameraAuthService()
    private let templateControllerView = TemplateControllerView()
    private let templateBarController = TemplateBarCollectionViewController(templates: [])
}

extension CollageSceneViewController: CollageViewControllerDelegate {
    func collageViewController(_ controller: CollageViewController, changed cellsCount: Int) {
        if let assets = templateBarController.templates.first?.assets {
            templateBarController.templates = CollageTemplateProvider.templates(for: cellsCount, assets: assets)
        }
    }
}

extension CollageSceneViewController: TemplateBarCollectionViewControllerDelegate {
    func templateBarCollectionViewController(_ controller: TemplateBarCollectionViewController, didSelect collageTemplate: CollageTemplate) {
        CollageTemplateProvider.collage(from: collageTemplate, size: .large) { [weak self] collage in
            self?.collageViewController.collage = collage
        }
    }
}

extension UIViewController {
    
    func addChild(_ controller: UIViewController, to container: UIView) {
        self.addChildViewController(controller)
        controller.view.frame = container.bounds
        container.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }
    
    func removeFromParent() {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
        didMove(toParentViewController: nil)
    }
}

extension CollageSceneViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension CollageSceneViewController: CollageToolbarDelegate {
    func collageToolbar(_ collageToolbar: CollageToolbar, itemTapped: CollageBarItem) {
        switch itemTapped.title {
        case "HORIZONTAL": collageViewController.splitSelectedCell(by: .horizontal)
        case "VERTICAL": collageViewController.splitSelectedCell(by: .vertical)
        case "ADD IMG": pickImage()
        case "DELETE": collageViewController.deleteSelectedCell()
        default: break
        }
    }
}

extension CollageSceneViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
            return
        }
        
        collageViewController.addImageToSelectedCell(image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

