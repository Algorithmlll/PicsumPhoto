//
//  AlbumsViewController.swift
//  PicsumPhoto
//
//  Created by Same Chinnawat on 15/9/2562 BE.
//  Copyright © 2562 Same Chinnawat. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class AlbumsViewController: UIViewController {
    
    @IBOutlet weak var collectionview: UICollectionView!
    
    var fetchResult: PHFetchResult<PHAsset>?
    var assetCollection: PHAssetCollection?
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAssets()
        
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.register(UINib(nibName: PhotoCollectionViewCell.identifier, bundle: .main), forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
    }
    
    /// UnregisterChangeObserver
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let width = (collectionview.frame.width / 3) - 15
        let height = width
        thumbnailSize = CGSize(width: width, height: height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getAssets()
    }
    
    func getAssets() {
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        
        // Do any additional setup after loading the view.
        let albumName = "PicsumPhoto"
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        var collection:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if collection.count == 0 {
            // Create a new album with the entered title.
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "PicsumPhoto")
            }, completionHandler: { success, error in
                if !success { print("Error creating album: \(String(describing: error)).") }
                collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                self.setAsset(collection: collection)
            })
            
        } else {
            setAsset(collection: collection)
        }
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        }
        
        collectionview.reloadData()
    }
    
    func setAsset(collection:PHFetchResult<PHAssetCollection>) {
        if let _:AnyObject = collection.firstObject{
            assetCollection = collection.firstObject!
        }
        
        fetchResult = PHAsset.fetchAssets(in: assetCollection!, options: nil)
    }
    
    // MARK: Asset Caching
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
    }
    
}


// MARK: PHPhotoLibraryChangeObserver
extension AlbumsViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
}


extension AlbumsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell
            else { fatalError("Unexpected cell in collection view") }
        
        let asset = fetchResult?.object(at: indexPath.item)
        cell.representedAssetIdentifier = asset?.localIdentifier
        imageManager.requestImage(for: asset!, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset?.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destination : DetailViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        destination.modalTransitionStyle = .crossDissolve
        destination.modalPresentationStyle = .overCurrentContext
        destination.display = .asset
        destination.asset = fetchResult?.object(at: indexPath.item)
        destination.assetCollection = assetCollection
        let navigationController = UINavigationController(rootViewController: destination)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionview.frame.width / 3) - 15
        let height = width
        
        return CGSize(width: width, height: height)
    }
    
}

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}
