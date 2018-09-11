//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit
import SnapKit

protocol ShareScreenViewControllerDelegate: AnyObject {
    func shareScreenViewControllerShouldBeClosed(_ controller: ShareScreenViewController)
}

class ShareScreenViewController: UIViewController {
    
    weak var delegate: ShareScreenViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        makeConstraints()
    }
    
    func setCollagePreview(image: UIImage) {
        collageImageView.image = image
    }
    
    private func setup() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        navigationItem.title = "Share"
        
        view.backgroundColor = .white
        view.addSubview(collageImageView)
    }
    
    private func makeConstraints() {
        collageImageView.snp.makeConstraints { make in
            if #available(iOS 11, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }
            
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(collageImageView.snp.width)
        }
    }
    
    @objc private func close() {
        delegate?.shareScreenViewControllerShouldBeClosed(self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private let collageImageView: UIImageView = {
        let view = UIImageView()
//        view.contentMode = .scaleAspectFit
        return view
    }()
}
