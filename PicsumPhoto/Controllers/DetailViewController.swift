//
//  DetailViewController.swift
//  PicsumPhoto
//
//  Created by Same Chinnawat on 14/9/2562 BE.
//  Copyright © 2562 Same Chinnawat. All rights reserved.
//

import UIKit
import Kingfisher
import Photos

class DetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    
    var downloadItem: UIBarButtonItem?
    
    var fetchResult: PHFetchResult<PHAsset>?
    var assetCollection: PHAssetCollection?
    var asset: PHAsset!
    var imageAsset: UIImage = UIImage()
    var display: DisplayPhoto = .cache
    
    var photoList: [Photo] = []
    var currentPage: Int = 0
    
    var isLoad = true
    var keyDownload: [String] = []
    let userManager = UserManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadItem = downloadButton
        keyDownload = userManager.getPhotoDownload() ?? []
        
        PHPhotoLibrary.shared().register(self)
        CheckAlbum()
        progressLabel.isHidden = true
        progressLabel.font = UIFont.systemFont(ofSize: 18)
        progressLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.orange]
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if display == .asset {
            updateStaticImage()
        } else {
            setupScrollView()
            title = photoList[currentPage].author
            move(index: currentPage)
        }
    }
    
    func setupScrollView() {
        let width = scrollView.frame.size.width
        let hight = scrollView.frame.size.height
        
        scrollView.contentSize = CGSize.init(width: width * CGFloat(photoList.count), height: hight)
        
        for (index,image) in photoList.enumerated() {
            let imageview = UIImageView()
            imageview.frame = CGRect(x: width * CGFloat(index), y: 0, width: width, height: hight)
            imageview.contentMode = .scaleAspectFit
            imageview.backgroundColor = UIColor.clear
            
            let key = "key-\(image.download_url)"
            imageview.kf.indicatorType = .image(imageData: gifData)
            ImageCache.default.retrieveImage(forKey: key, options: [.onlyFromCache]) { image, cacheType in
                imageview.image = image
            }
            scrollView.addSubview(imageview)
        }
        
        if photoList.count < 2 {
            self.backButton.isHidden = true
            self.nextButton.isHidden = true
        } else {
            self.backButton.isHidden = false
            self.nextButton.isHidden = false
        }
    
    }
    
    func move(index: Int) {
        let width = scrollView.frame.size.width
        let hight = scrollView.frame.size.height
        title = photoList[currentPage].author
        checkDownload(url: "\(photoList[currentPage].download_url)")
        scrollView.scrollRectToVisible(CGRect.init(x: width * CGFloat(index), y: 0, width: width, height: hight), animated: false)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        currentPage = Int(pageNumber)
        title = photoList[currentPage].author
        checkDownload(url: "\(photoList[currentPage].download_url)")
    }
    
    func checkDownload(url: String) {
        print("url :: \(url)")
        print("keyDownload :: \(keyDownload)")
        if keyDownload.contains(where: {$0 == url}) {
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationItem.rightBarButtonItem = downloadItem
        }
    }
    
    // MARK: - Action
    
    @IBAction func closeAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func downloadAction(_ sender: UIBarButtonItem) {
        if isLoad && !keyDownload.contains("\(photoList[currentPage].download_url)") {
            isLoad = false
            let downloader = ImageDownloader.default
            progressLabel.isHidden = false
            downloader.downloadImage(with: photoList[currentPage].download_url,
                                     options: nil,
                                     progressBlock: { (receivedSize, totalSize) in
                                        let percentage = (Float(receivedSize) / Float(totalSize)) * 100.0
                                        let message = """
                                        Author \(self.photoList[self.currentPage].author)
                                        downloading
                                        progress: \(percentage)%
                                        \(receivedSize)/\(totalSize) kb
                                        """
                                        self.progressLabel.text = message
            }) { (result) in
                self.isLoad = true
                switch result {
                case .success(let value):
                    print(value.image)
                    self.addAsset(image: value.image)
                    self.keyDownload.append("\(self.photoList[self.currentPage].download_url)")
                    self.userManager.setPhotoDownload(value: self.keyDownload)
                    self.progressLabel.text = "Download success!!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.progressLabel.isHidden = true
                    }
                case .failure(let error):
                    self.progressLabel.text = error.errorDescription
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.progressLabel.isHidden = true
                    }
                }
            }
            
        }
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        if currentPage < photoList.count - 1 {
            currentPage += 1
            move(index: currentPage)
        }
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        if currentPage > 0 && currentPage <= photoList.count - 1 {
            currentPage -= 1
            move(index: currentPage)
        }
    }
    
    /// - Tag: CreateAlbum
    func CheckAlbum() {
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
            self.setAsset(collection: collection)
        }
    }
    
    func setAsset(collection:PHFetchResult<PHAssetCollection>) {
        if let _:AnyObject = collection.firstObject{
            assetCollection = collection.firstObject!
        }
        
        fetchResult = PHAsset.fetchAssets(in: assetCollection!, options: nil)
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        }
    }
    
    /// - Tag: AddAsset
    func addAsset(image: Image) {
        // Add the asset to the photo library.
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if let assetCollection = self.assetCollection {
                let addAssetRequest = PHAssetCollectionChangeRequest(for: assetCollection)
                addAssetRequest?.addAssets([creationRequest.placeholderForCreatedAsset!] as NSArray)
            }
        }, completionHandler: {success, error in
            if !success { print("Error creating the asset: \(String(describing: error))") }
        })
    }
    
    // MARK: Image display
    
    func updateStaticImage() {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, _, _, _ in }
        
        PHImageManager.default().requestImage(for: asset, targetSize: scrollView.frame.size, contentMode: .aspectFit, options: options,
                                              resultHandler: { image, _ in
                                                // PhotoKit finished the request, so hide the progress view.
                                                
                                                // If the request succeeded, show the image view.
                                                guard let image = image else { return }
                                                self.imageAsset = image
                                                self.setupScrollViewAsset()
        })
    }
    
    func setupScrollViewAsset() {
        let width = scrollView.frame.size.width
        let hight = scrollView.frame.size.height
        scrollView.contentSize = CGSize.init(width: width * CGFloat(photoList.count), height: hight)
        
        let imageview = UIImageView()
        imageview.frame = CGRect(x: 0, y: 0, width: width, height: hight)
        imageview.contentMode = .scaleAspectFit
        imageview.backgroundColor = UIColor.clear
        imageview.image = self.imageAsset
        imageview.kf.indicatorType = .image(imageData: gifData)
        
        scrollView.addSubview(imageview)
        
        self.navigationItem.rightBarButtonItem = nil
        self.backButton.isHidden = true
        self.nextButton.isHidden = true
        
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension DetailViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
}
