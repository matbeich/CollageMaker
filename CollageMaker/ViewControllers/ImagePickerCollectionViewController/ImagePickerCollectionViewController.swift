//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit
import Photos

class ImagePickerCollectionViewController: UIViewController {
    
    init(assets: [PHAsset]) {
        self.photoAssets = assets
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        
        collectionView.register(ImagePickerCollectionViewCell.self, forCellWithReuseIdentifier: ImagePickerCollectionViewCell.identifier)
    }
    
    private var photoAssets: [PHAsset] {
        willSet{
            PhotoLibraryService.stopCaching()
        }
        didSet {
            PhotoLibraryService.cacheImages(for: self.photoAssets)
            collectionView.reloadData()
        }
    }
    private var collectionView: UICollectionView
}

extension ImagePickerCollectionViewController: UICollectionViewDelegate & UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: ImagePickerCollectionViewCell.identifier, for: indexPath)
        
        guard let pickerCell = cell as? ImagePickerCollectionViewCell else {
            return cell
        }
        
        pickerCell.photoAsset = photoAssets[indexPath.row]
        
        return pickerCell
    }
}

extension ImagePickerCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize
    }
    
    
}
