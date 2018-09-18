//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit
import Photos

protocol ImagePickerCollectionViewControllerDelegate: AnyObject {
    func imagePickerCollectionViewController(_ controller: ImagePickerCollectionViewController, didSelect assets: [PHAsset])
}

class ImagePickerCollectionViewController: UIViewController {
    
    weak var delegate: ImagePickerCollectionViewControllerDelegate?
    
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
        view.addSubview(collectionView)
    }
    
    private func setup() {
        navigationItem.title = "All Photos"
        
        collectionView.backgroundColor = .white
        collectionView.frame = view.bounds
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        
        collectionView.register(ImagePickerCollectionViewCell.self, forCellWithReuseIdentifier: ImagePickerCollectionViewCell.identifier)
    }
    
    private func asset(for indexPath: IndexPath) -> PHAsset? {
        return photoAssets[indexPath.row]
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var selectedAssets: [PHAsset] {
        return selectedCellsIndexPaths.compactMap { asset(for: $0) }
    }
    
    private var collectionView: UICollectionView
    private var selectedCellsIndexPaths: [IndexPath] = []
}

extension ImagePickerCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: ImagePickerCollectionViewCell.identifier, for: indexPath)
        
        guard let pickerCell = cell as? ImagePickerCollectionViewCell else {
            return cell
        }
        
        pickerCell.photoAsset = photoAssets[indexPath.row]
        if selectedCellsIndexPaths.contains(indexPath) {
            DispatchQueue.main.async {
                pickerCell.cellSelected = true
            }
        }
    
        return pickerCell
    }
}

extension ImagePickerCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImagePickerCollectionViewCell else {
            return
        }
        
        if selectedCellsIndexPaths.contains(indexPath) {
            selectedCellsIndexPaths = selectedCellsIndexPaths.filter { $0 != indexPath }
        } else {
            selectedCellsIndexPaths.append(indexPath)
        }
        
        cell.toogleSelection()
   
        delegate?.imagePickerCollectionViewController(self, didSelect: selectedAssets)
    }
}

extension ImagePickerCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.bounds.width - 2 * 5 ) / 4
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(repeated: 2)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}
