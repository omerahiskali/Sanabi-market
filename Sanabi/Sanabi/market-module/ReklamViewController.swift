//
//  ReklamViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 1.06.2023.
//

import UIKit

class ReklamViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var reklamCollectionView: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    
    let reklamArray = [UIImage(named: "reklam_1")!,UIImage(named: "reklam_2")!,UIImage(named: "reklam_3")!,UIImage(named: "reklam_4")!,UIImage(named: "reklam_5")!,UIImage(named: "reklam_6")!,UIImage(named: "reklam_7")!,UIImage(named: "reklam_8")!,UIImage(named: "reklam_9")!,UIImage(named: "reklam_10")!]
    
    var timer: Timer?
    var currentCellIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reklamCollectionView.delegate = self
        reklamCollectionView.dataSource = self
        
        pageController.numberOfPages = reklamArray.count
        
        startTimer()
        
        configureCollectionViewLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        reklamCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopTimer()
    }
    
    func configureCollectionViewLayout() {
        if let layout = reklamCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = reklamCollectionView.frame.size
            layout.minimumLineSpacing = 0
            layout.scrollDirection = .horizontal
        }
        
        reklamCollectionView.isPagingEnabled = true
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(moveToNextIndex), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func moveToNextIndex() {
        currentCellIndex += 1
        if currentCellIndex >= reklamArray.count {
            currentCellIndex = 0
        }
        
        let offsetX = reklamCollectionView.frame.width * CGFloat(currentCellIndex)
        let contentOffset = CGPoint(x: offsetX, y: 0)
        reklamCollectionView.setContentOffset(contentOffset, animated: true)
        
        pageController.currentPage = currentCellIndex
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startTimer()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reklamArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reklamCell", for: indexPath) as! ReklamCollectionViewCell
        cell.image.image = reklamArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
    
class ReklamCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var image: UIImageView!
}
