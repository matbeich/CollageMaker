//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Photos
import SnapKit
import UIKit
import Utils

protocol PermissionsViewControllerDelegate: AnyObject {
    func permissionViewControllerDidReceivePermission(_ controller: PermissionsViewController)
}

class PermissionsViewController: CollageBaseViewController {
    weak var delegate: PermissionsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(allowButton)
        view.addSubview(subtitleLabel)
        view.addSubview(bottomStackView)

        makeConstraints()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    private func makeConstraints() {
        let sideOffset = UIScreen.main.bounds.width * 0.15
        let topOffset = UIScreen.main.bounds.height * 0.26

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(topOffset)
            make.left.equalToSuperview().offset(sideOffset)
            make.right.equalToSuperview().offset(-sideOffset)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(UIScreen.main.bounds.height * 0.02)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
        }

        allowButton.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width * 0.25)
        }

        bottomStackView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.top.equalTo(subtitleLabel.snp.bottom).offset(topOffset)
            make.bottom.equalToSuperview().offset(-sideOffset)
        }
    }

    @objc private func showCollageScene() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async { self?.handle(status) }
        }
    }

    private func handle(_ authorizationStatus: PHAuthorizationStatus) {
        if case .authorized = authorizationStatus {
            delegate?.permissionViewControllerDidReceivePermission(self)
            return
        }

        guard let alertController = Alerts.alert(for: authorizationStatus) else {
            assert(false, "can't handle authorization status \(authorizationStatus)")
            return
        }

        present(alertController, animated: true, completion: nil)
    }

    private lazy var allowButton: UIButton = {
        let button = GradientButton(type: .system)

        button.setTitle("Allow", for: .normal)
        button.addTarget(self, action: #selector(showCollageScene), for: .touchUpInside)
        button.titleLabel?.font = R.font.sfProDisplayHeavy(size: 19)

        return button
    }()

    private lazy var titleLabel: AttributedTextLabel = {
        let label = AttributedTextLabel(text: "Start Your Masterpiece")

        label.font = R.font.sfProDisplayHeavy(size: 46)
        label.letterSpacing = -1.85
        label.sizeToFit()
        label.addAttributes(attrs: [NSAttributedStringKey.foregroundColor: UIColor.brightLavender], to: label.lastWord ?? "")

        return label
    }()

    private let subtitleLabel: AttributedTextLabel = {
        let label = AttributedTextLabel(text: "The best photos are already here, make them speak")
        label.font = R.font.sfProDisplayRegular(size: 15)
        label.sizeToFit()

        return label
    }()

    private let accessLabel: AttributedTextLabel = {
        let label = AttributedTextLabel(text: "Access to Photos")
        label.font = R.font.sfProDisplayHeavy(size: 25)
        label.letterSpacing = -1.0
        label.sizeToFit()

        return label
    }()

    private let accessMessageLabel: AttributedTextLabel = {
        let label = AttributedTextLabel(text: "Collagist needs access to photos to turn them into masterpieces.")
        label.font = R.font.sfProDisplayRegular(size: 15)
        label.sizeToFit()

        return label
    }()

    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [accessLabel, accessMessageLabel, allowButton])

        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .leading
        stackView.spacing = 5

        return stackView
    }()
}

private extension Alerts {
    static func alert(for status: PHAuthorizationStatus) -> UIAlertController? {
        switch status {
        case .denied: return Alerts.photoAccessDenied()
        case .restricted: return Alerts.photoAccessRestricted()
        case .authorized, .notDetermined: return nil
        }
    }
}
