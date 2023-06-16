//
//  MarketKategoriViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 1.06.2023.
//

import UIKit
import Alamofire

class MarketKategoriViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var marketImage: UIImageView!
    @IBOutlet weak var gonderimContainer: UIView!
    @IBOutlet weak var kategoriCollectionView: UICollectionView!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var cartImage: UIImageView!
    @IBOutlet weak var categorySearchBar: UISearchBar!
    
    // MARK: - Variables
    
    var categoryList = [Categorys]()
    let headers: HTTPHeaders = [
        "Content-Type": "application/json"
    ]
    let imageCache = NSCache<NSString, UIImage>()
    
    // MARK: - View Funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        takeCategorys()
        
        kategoriCollectionView.delegate = self
        kategoriCollectionView.dataSource = self
        
        categorySearchBar.delegate = self

        marketImage.layer.cornerRadius = 10
        marketImage.clipsToBounds = true
        marketImage.layer.borderWidth = 0.1
        marketImage.layer.borderColor = UIColor.darkGray.cgColor
        
        gonderimContainer.layer.cornerRadius = 12
        gonderimContainer.clipsToBounds = true
        gonderimContainer.layer.borderWidth = 0.5
        gonderimContainer.layer.borderColor = UIColor.gray.cgColor
        
        let backImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(backImageViewTapped))
        backImage.addGestureRecognizer(backImageTapGesture)
        backImage.isUserInteractionEnabled = true
        
        let cartImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(cartImageViewTapped))
        cartImage.addGestureRecognizer(cartImageTapGesture)
        cartImage.isUserInteractionEnabled = true
        
    }
    
    // MARK: - Funcs
    
    func takeCategorys() {
        let url = "https://ozerhamza.xyz/api/Category"
        
        AF.request(url).responseDecodable(of: CategoryList.self) { response in
            switch response.result {
            case .success(let value):
                if let data = value.data{
                    self.categoryList = data
                } else {
                    print("Hatalı API yanıtı")
                    self.categoryList = [Categorys]()
                }
                DispatchQueue.main.async {
                    self.kategoriCollectionView.reloadData()
                }
            case .failure(let error):
                print("Hata oluştu: \(error.localizedDescription)")
            }
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let urunlerVC = storyboard.instantiateViewController(withIdentifier: "searchBarVC") as? SearchBarViewController{
            
            urunlerVC.modalTransitionStyle = .coverVertical
            urunlerVC.modalPresentationStyle = .fullScreen
            
            present(urunlerVC, animated: true, completion: nil)
        }
        return false
    }
    
    // MARK: - objc Funcs
    
    @objc func backImageViewTapped(){
        dismiss(animated: true)
    }
    
    @objc func cartImageViewTapped(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let urunlerVC = storyboard.instantiateViewController(withIdentifier: "sepetVC") as? SepetViewController {
            
            urunlerVC.modalTransitionStyle = .coverVertical
            urunlerVC.modalPresentationStyle = .fullScreen
            
            present(urunlerVC, animated: true, completion: nil)
        }
    }

}

    // MARK: - Extensions

extension MarketKategoriViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = categoryList[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "kategoriCell", for: indexPath) as! KategoriCollectionViewCell
            
            // Hücrenin eski verilerini temizle
        cell.prepareForReuse()
            
        cell.kategoriLabel.text = category.name
            
            // Varsayılan veya yer tutucu resim
        cell.kategoriImage.image = UIImage(named: "placeholderImage")
        
        cell.kategoriImage.layer.cornerRadius = cell.kategoriImage.bounds.height/2
        cell.kategoriImage.clipsToBounds = true
        cell.kategoriImage.layer.borderWidth = 0.2
        cell.kategoriImage.layer.borderColor = UIColor.darkGray.cgColor
            
            // Resmi önbellekte kontrol et
        if let cachedImage = imageCache.object(forKey: category.image as NSString) {
            cell.kategoriImage.image = cachedImage
        } else {
            if let url = URL(string: "https://ozerhamza.com.tr/img/\(category.image)") {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                            // Resmi önbelleğe kaydet
                        self.imageCache.setObject(image, forKey: category.image as NSString)
                            
                        DispatchQueue.main.async {
                                // Hücre hala görüntüleniyorsa resmi güncelle
                            if let updateCell = collectionView.cellForItem(at: indexPath) as? KategoriCollectionViewCell {
                                updateCell.kategoriImage.image = image
                            }
                        }
                    }
                }
            }
        }
            
            return cell
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedId = categoryList[indexPath.row].id
        print("Seçilen id: \(selectedId)")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let urunlerVC = storyboard.instantiateViewController(withIdentifier: "urunlerVC") as? UrunlerViewController {
            urunlerVC.id = selectedId
            urunlerVC.categoryList = categoryList
            urunlerVC.indexPos = indexPath
            
            urunlerVC.modalTransitionStyle = .coverVertical
            urunlerVC.modalPresentationStyle = .fullScreen
            
            present(urunlerVC, animated: true, completion: nil)
        }
    }

    
    
}

    // MARK: - Classes

class KategoriCollectionViewCell: UICollectionViewCell{
    
    @IBOutlet weak var kategoriImage: UIImageView!
    @IBOutlet weak var kategoriLabel: UILabel!
    
    
}
