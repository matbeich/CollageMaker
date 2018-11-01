//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit

protocol PreviewViewControllerDelegate: AnyObject {
    func previewViewController(_ controller: PreviewViewController, didChooseAction action: PreviewViewController.Action)
}

class PreviewViewController: UIViewController {
    enum Action {
        case delete
        case dismiss
    }

    weak var delegate: PreviewViewControllerDelegate?

    init(image: UIImage) {
        self.imageView.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        modalPresentationStyle = .overCurrentContext
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        view.addSubview(imageView)
        makeConstraints()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        layout()

        if !isBeingPresented && !isBeingDismissed {
            showControls()
            showBlur()
        }
    }

    private func layout() {
        guard let image = imageView.image else {
            return
        }

        imageView.layer.cornerRadius = 10
        let scale = min(view.bounds.width / image.size.width, view.bounds.height / imageView.bounds.size.height)
        view.bounds.size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
    }

    private func makeConstraints() {
        imageView.snp.makeConstraints { make in
            make.size.equalToSuperview().multipliedBy(0.95)
            make.center.equalToSuperview()
        }
    }

    private func showBlur() {
        effectView.bounds.size = UIScreen.main.bounds.size
        effectView.center = view.convert(view.center, from: nil)

        view.insertSubview(effectView, belowSubview: imageView)
    }

    private func hideBlur() {
        effectView.alpha = 0
        effectView.contentView.removeFromSuperview()
        effectView.removeFromSuperview()
    }

    private func showControls() {
        let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let dismiss = UIAlertAction(title: "Dismiss", style: .default) { [weak self] _ in
            guard let `self` = self else {
                return
            }

            self.hideBlur()
            self.delegate?.previewViewController(self, didChooseAction: .dismiss)
        }

        let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let `self` = self else {
                return
            }

            self.hideBlur()
            self.delegate?.previewViewController(self, didChooseAction: .delete)
        }

        alertView.addAction(delete)
        alertView.addAction(dismiss)

        present(alertView, animated: true, completion: nil)
    }

    private let imageView = UIImageView()
    private let effectView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)

        return UIVisualEffectView(effect: blur)
    }()
}
