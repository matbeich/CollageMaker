//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Photos
import SnapKit
import UIKit
import Utils

protocol TemplatePickerViewControllerDelegate: AnyObject {
    func templatePickerViewController(_ controller: TemplatePickerViewController, templateController: TemplateBarCollectionViewController, didSelect template: CollageTemplate)
}

class TemplatePickerViewController: CollageBaseViewController {
    weak var delegate: TemplatePickerViewControllerDelegate?

    var templateViewIsVisible: Bool {
        return templateController.templates.count > 0
    }

    init(assets: [PHAsset] = []) {
        self.assets = assets
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        view.addSubview(mainControllerContainer)
        view.addSubview(templateControllerContainer)

        makeConstraints()

        addChild(imagePickerController, to: mainControllerContainer)
        addChild(templateController, to: templateControllerContainer.templateContainerView)

        templateController.delegate = self
        imagePickerController.delegate = self
    }

    private func setup() {
        imagePickerController.photoAssets = assets

        let left = NavigationBarButtonItem(icon: R.image.camera_btn(), target: self, action: #selector(handle(_:)))
        let title = NavigationBarLabelItem(title: "All Photos", color: .black, font: R.font.sfProDisplaySemibold(size: 19))
        let right = NavigationBarViewItem(view: gradientButton)

        gradientButton.addTarget(self, action: #selector(selectTemplate), for: .touchUpInside)
        navBarItem = NavigationBarItem(left: left, right: right, title: title)
    }

    @objc private func selectTemplate() {
        guard let template = templateController.templates.first else {
            return
        }

        select(template: template)
    }

    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return
        }

        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.delegate = self

        present(controller, animated: true)
    }

    @objc private func handle(_ avAuthorizationStatus: AVAuthorizationStatus) {
        if cameraAuthService.isAuthorized {
            openCamera()
            return
        }

        switch avAuthorizationStatus {
        case .notDetermined: cameraAuthService.reqestAuthorization { self.handle($0) }
        case .denied: present(Alerts.cameraAccessDenied(), animated: true, completion: nil)
        case .restricted: present(Alerts.cameraAccessRestricted(), animated: true, completion: nil)
        default: break
        }
    }

    private func showTemplateController() {
        if !templateViewIsVisible {
            templateControllerContainer.snp.updateConstraints { make in
                make.top.equalTo(view.snp.bottom).offset(-templateControllerContainer.frame.height)
            }

            view.layoutIfNeeded()
        }
    }

    private func hideTemplateController() {
        if templateViewIsVisible {
            templateControllerContainer.snp.updateConstraints { make in
                make.top.equalTo(view.snp.bottom).offset(-50)
            }

            view.layoutIfNeeded()
        }
    }

    private func select(template: CollageTemplate) {
        CollageTemplateProvider.collage(from: template, size: .large) { collage in
            self.delegate?.templatePickerViewController(self, templateController: self.templateController, didSelect: template)
        }
    }

    private func makeConstraints() {
        templateControllerContainer.snp.updateConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(view.snp.bottom).offset(-50)
            make.height.equalTo(view.bounds.height / 3.5)
        }

        mainControllerContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
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
        let button = GradientButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 25)))
        button.setTitle("0", for: .normal)
        button.setImage(R.image.confirm_btn(), for: .normal)
        button.showShadow = false
        button.titleLabel?.font = R.font.sfProDisplaySemibold(size: 17)
        button.contentHorizontalAlignment = .fill

        return button
    }()

    private var assets: [PHAsset]
    private let mainControllerContainer = UIView(frame: .zero)
    private let cameraAuthService = CameraAuthService()
    private let templateControllerContainer = TemplateControllerView(frame: .zero, headerText: "Choose template")
    private var imagePickerController = ImagePickerCollectionViewController(assets: [])
    private var templateController = TemplateBarCollectionViewController(templates: [])
}

extension TemplatePickerViewController: ImagePickerCollectionViewControllerDelegate {
    func imagePickerCollectionViewControllerShouldDismiss(_ controller: ImagePickerCollectionViewController) {}

    func imagePickerCollectionViewController(_ controller: ImagePickerCollectionViewController, didSelectAssets assets: [PHAsset]) {
        view.layoutIfNeeded()
        selectedAssets = assets

        let templates = CollageTemplateProvider.templates(for: selectedAssets)
        let animation = templates.isEmpty ? { self.hideTemplateController() } : { self.showTemplateController() }

        UIView.animate(withDuration: 0.2, animations: animation)
        templateController.templates = templates
    }
}

extension TemplatePickerViewController: TemplateBarCollectionViewControllerDelegate {
    func templateBarCollectionViewController(_ controller: TemplateBarCollectionViewController, didSelect collageTemplate: CollageTemplate) {
        delegate?.templatePickerViewController(self, templateController: controller, didSelect: collageTemplate)
    }
}

extension TemplatePickerViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)

        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
            return
        }

        PhotoLibraryService.add(image) { [weak self] success in
            assert(success, "Unable to write asset to photo library")
            self?.imagePickerController.photoAssets = PhotoLibraryService.getImagesAssets()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
