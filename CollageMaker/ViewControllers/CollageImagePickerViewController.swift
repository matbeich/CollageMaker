//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit
import SnapKit

class CollageImagePickerViewController: UIViewController {
    
    init(main: UIViewController, template: UIViewController) {
        mainController = main
        templateController = template
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(mainController, to: view)
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
    
    private var mainController: UIViewController
    private var templateController: UIViewController
    private let templateControllerContainer = UIView()
}
