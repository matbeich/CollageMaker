//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Photos
import SnapKit
import UIKit
import Utils

protocol TemplatePickerViewControllerDelegate: AnyObject {
    func templatePickerViewController(_ controller: TemplatePickerViewController, templateController: TemplateBarCollectionViewController, didSelectTemplate template: CollageTemplate)
}

class TemplatePickerViewController: CollageBaseViewController {
    weak var delegate: TemplatePickerViewControllerDelegate?

    var selectedCellsCount: Int {
        return imagePickerController.selectedAssets.count
    }

    var templateViewIsVisible: Bool {
        return view.bounds.contains(templatesView.frame) && !templatesView.frame.isEmpty
    }

    var templateViewIsEmpty: Bool {
        return templateController.templates.count <= 0
    }

    init(context: AppContext) {
        self.context = context
        self.templateController = TemplateBarCollectionViewController(context: context)
        self.imagePickerController = ImagePickerCollectionViewController(context: context,
                                                                         selectionMode: .multiply(context.remoteSettingsService.cellsCount))

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        tokens.removeAll()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        view.addSubview(mainControllerContainer)
        view.addSubview(templatesView)

        makeConstraints()

        addChild(imagePickerController, to: mainControllerContainer)
        addChild(templateController, to: templatesView.contentView)

        templateController.delegate = self
        imagePickerController.delegate = self
    }

    private func setup() {
        view.backgroundColor = .white

        navBarItem.left = NavigationBarButtonItem(icon: R.image.camera_btn(), target: self, action: #selector(takePhoto))
        navBarItem.right = NavigationBarViewItem(view: gradientButton)
        navBarItem.title = "All Photos"

        gradientButton.addTarget(self, action: #selector(selectFirstTemplate), for: .touchUpInside)
        context.remoteSettingsService.fetchRemoteSettings()

        tokens.append(context.remoteSettingsService.subscribe(on: .main) { [weak self] in
            self?.imagePickerController.mode = .multiply($0.numberOfCells)
        })
    }

    @objc private func selectFirstTemplate() {
        guard let template = templateController.templates.first else {
            return
        }

        select(template: template)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let offset = templateViewIsVisible ? templatesView.frame.height : 50
        imagePickerController.contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: offset - view.safeAreaInsets.bottom, right: 0)
    }

    @objc private func takePhoto() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return
        }

        handle(context.cameraAuthService.status)
    }

    @objc private func handle(_ avAuthorizationStatus: AVAuthorizationStatus) {
        if context.cameraAuthService.isAuthorized {
            let controller = UIImagePickerController()
            controller.sourceType = .camera
            controller.delegate = self

            present(controller, animated: true)
            return
        }

        switch avAuthorizationStatus {
        case .notDetermined: context.cameraAuthService.reqestAuthorization { self.handle($0) }
        case .denied: present(Alerts.cameraAccessDenied(), animated: true, completion: nil)
        case .restricted: present(Alerts.cameraAccessRestricted(), animated: true, completion: nil)
        default: break
        }
    }

    private func setTemplateViewIsVisible(_ visible: Bool) {
        guard templateViewIsVisible != visible else {
            return
        }

        let offset = visible ? templatesView.frame.height : 50

        templatesView.snp.updateConstraints { make in
            make.top.equalTo(view.snp.bottom).offset(-offset)
        }

        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }

    private func select(template: CollageTemplate) {
        delegate?.templatePickerViewController(self, templateController: templateController, didSelectTemplate: template)
    }

    private func makeConstraints() {
        templatesView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.snp.bottom).offset(-50)
            make.height.equalTo(view.bounds.height / 3.5)
        }

        mainControllerContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    private var selectedAssets: [PHAsset] = [] {
        willSet {
            context.photoLibrary.stopCaching()
        } didSet {
            context.photoLibrary.cacheImages(with: selectedAssets)
            gradientButton.setTitle("\(selectedAssets.count)", for: .normal)
        }
    }

    private let gradientButton: GradientButton = {
        let button = GradientButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 25)))
        button.setTitle("0", for: .normal)
        button.setImage(R.image.confirm_btn(), for: .normal)
        button.showShadow = false
        button.titleLabel?.font = R.font.sfProDisplaySemibold(size: 17)
        button.contentHorizontalAlignment = .fill
        button.accessibilityIdentifier = Accessibility.NavigationControl.select.id

        return button
    }()

    private var tokens = [Any]()
    private let context: AppContext
    private let mainControllerContainer = UIView()
    private let templatesView = TemplatesView(headerText: "Choose template")
    private var imagePickerController: ImagePickerCollectionViewController
    private var templateController: TemplateBarCollectionViewController
}

extension TemplatePickerViewController: ImagePickerCollectionViewControllerDelegate {
    func imagePickerCollectionViewControllerDidCancel(_ controller: ImagePickerCollectionViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func imagePickerCollectionViewController(_ controller: ImagePickerCollectionViewController, didSelectAssets assets: [PHAsset]) {
        view.layoutIfNeeded()
        selectedAssets = assets

        templateController.templates = context.templateProvider.templates(for: selectedAssets)
        setTemplateViewIsVisible(templateViewIsEmpty ? false : true)
    }
}

extension TemplatePickerViewController: TemplateBarCollectionViewControllerDelegate {
    func templateBarCollectionViewController(_ controller: TemplateBarCollectionViewController, didSelect collageTemplate: CollageTemplate) {
        delegate?.templatePickerViewController(self, templateController: controller, didSelectTemplate: collageTemplate)
    }
}

extension TemplatePickerViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)

        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
            return
        }

        context.photoLibrary.add(image) { success, asset in
            assert(success, "Unable to write asset to photo library")
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
