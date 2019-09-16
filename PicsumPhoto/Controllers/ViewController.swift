//
//  ViewController.swift
//  PicsumPhoto
//
//  Created by Same Chinnawat on 12/9/2562 BE.
//  Copyright © 2562 Same Chinnawat. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    
    var photoList: [Photo] = []
    var cache: ImageCache = ImageCache.default
    var tableHeight: [Float] = []
    
    var currentPage = 1
    var isLoadMore = false
    let userManager = UserManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        settingCache()
        fetchPhotolist()
        
        tableview.prefetchDataSource = self
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UINib.init(nibName: PhotoTableViewCell.identifier, bundle: .main), forCellReuseIdentifier: PhotoTableViewCell.identifier)
    }
    
    func fetchPhotolist() {
        
        APIClient.photoList(page: currentPage) { (result) in
            switch result {
            case .success(let photos):
                if self.isLoadMore {
                    let temp = photos
                    self.photoList += temp
                } else {
                    self.photoList = photos
                }
                self.tableHeight = self.calHeight(photos: self.photoList)
                self.tableview.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func calHeight(photos: [Photo]) -> [Float] {
        var tableHeight: [Float] = []
        for photo in photos {
            let imgWidth = photo.width
            let imgHeight = photo.height
            let height = scaled(with: UIScreen.main.bounds.size.width, imgSize: CGSize(width: imgWidth, height: imgHeight))
            tableHeight.append(Float(height))
        }
        return tableHeight
    }
    
    func scaled(with width: CGFloat, imgSize: CGSize) -> CGFloat {
        let ratio = imgSize.width / imgSize.height
        let height = width / ratio
        return height
    }
    
    func settingCache() {
        // Limit memory cache size to 300 MB.
        cache.memoryStorage.config.totalCostLimit = 300 * 1024 * 1024
        
        // Limit memory cache to hold 150 images at most.
        cache.memoryStorage.config.countLimit = 10
        
        // Limit disk cache size to 1 GB.
        cache.diskStorage.config.sizeLimit = 1000 * 1024 * 1024
        
        // Memory image expires after 10 minutes.
        cache.memoryStorage.config.expiration = .seconds(6)
        
        // Disk image never expires.
        cache.diskStorage.config.expiration = .never
        
    }
    
    
    func displayWithIndex(index: Int) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destination : DetailViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        destination.modalTransitionStyle = .crossDissolve
        destination.modalPresentationStyle = .overCurrentContext
        destination.photoList = photoList
        destination.currentPage = index
        //        self.present(destination, animated: true, completion: nil)
        let navigationController = UINavigationController(rootViewController: destination)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    
    @IBAction func performKingfisherAction(_ sender: UIBarButtonItem) {
        showSimpleActionSheet(controller: self, sender: sender)
    }
    
    func showSimpleActionSheet(controller: UIViewController, sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Action", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.barButtonItem = sender
        alert.popoverPresentationController?.permittedArrowDirections = .any
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cleanCacheAction())
        alert.addAction(reloadAction())
//        alert.addAction(calculateDiskStorageSize())
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func cleanCacheAction() -> UIAlertAction {
        return UIAlertAction(title: "Clean Cache", style: .default) { _ in
            KingfisherManager.shared.cache.clearMemoryCache()
            KingfisherManager.shared.cache.clearDiskCache()
            self.userManager.clearPhotoDownload()
            self.currentPage = 1
            self.tableview.reloadData()
        }
    }
    
    func reloadAction() -> UIAlertAction {
        return UIAlertAction(title: "Reload", style: .default) { _ in
            self.currentPage = 1
            self.tableview.reloadData()
        }
    }
    
    func calculateDiskStorageSize() -> UIAlertAction {
        return UIAlertAction(title: "DiskStorage", style: .default) { _ in
            ImageCache.default.calculateDiskStorageSize { result in
                switch result {
                case .success(let size):
                    print("Disk cache size: \(Double(size) / 1024 / 1024) MB")
                case .failure(let error):
                    print(error)
                }
            }
            
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(tableHeight[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoList.count
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap { photoList[$0.row].download_url }
        ImagePrefetcher(urls: urls).start()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell  = tableView.dequeueReusableCell(withIdentifier: PhotoTableViewCell.identifier, for: indexPath) as? PhotoTableViewCell else {
            fatalError("Wrong Cell: \(PhotoTableViewCell.identifier)")
        }
        
        // Mark each row as a new image.
        let cacheKey = "key-\(photoList[indexPath.row].download_url)"
        let resource = ImageResource(downloadURL: photoList[indexPath.row].download_url, cacheKey: cacheKey)
        cell.photoView.kf.indicatorType = .image(imageData: gifData)
        cell.photoView.kf.setImage(with: resource,
                                   options: nil,
                                   progressBlock: { receivedSize, totalSize in
                                    print("\(indexPath.row + 1): \(receivedSize)/\(totalSize)")
                                    
                                    let percentage = (Float(receivedSize) / Float(totalSize)) * 100.0
                                    print("downloading progress: \(percentage)%")
                                    
        }, completionHandler: { result in
            print("\(indexPath.row + 1): Finished")
        })
        
        
        cell.titleLabel.text = photoList[indexPath.row].author
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        displayWithIndex(index: indexPath.row)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10.0 {
            // Limit 5 page
            if currentPage < 5 {
                currentPage += 1
                self.fetchPhotolist()
                self.isLoadMore = true
            }
        }
    }
    
}
