//
//  UrunlerViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 1.06.2023.
//

import UIKit
import Alamofire

class UrunlerViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var urunCollectionView: UICollectionView!
    @IBOutlet weak var urunKategoriCollectionView: UICollectionView!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var searchImage: UIImageView!
    
    // MARK: - Variables
    
    var id:Int?
    var productList = [Products]()
    var productByCategoryList = [Products]()
    let headers: HTTPHeaders = [
        "Content-Type": "application/json"
    ]
    let imageCache = NSCache<NSString, UIImage>()
    var categoryList = [Categorys]()
    var indexPos:IndexPath?
    var selectedCategoryIndexPath: IndexPath?

    // MARK: - View Funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(id!)
        
        takeProducts()
        
        urunCollectionView.delegate = self
        urunCollectionView.dataSource = self
        
        urunKategoriCollectionView.delegate = self
        urunKategoriCollectionView.dataSource = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.collectionView(self.urunKategoriCollectionView, didSelectItemAt: self.indexPos!)
         }
        
        let backImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(backImageViewTapped))
        backImage.addGestureRecognizer(backImageTapGesture)
        backImage.isUserInteractionEnabled = true
        
        let searchImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(searchImageTapped))
        searchImage.addGestureRecognizer(searchImageTapGesture)
        searchImage.isUserInteractionEnabled = true
        
    }
    
    // MARK: - Funcs

    func takeProducts() {
        let url = "https://ozerhamza.xyz/api/Products"
        
        AF.request(url).responseDecodable(of: ProductList.self) { response in
            switch response.result {
            case .success(let value):
                if let data = value.data{
                    self.productList = data
                    print("productList count : \(self.productList.count)")
                } else {
                    print("Hatalı API yanıtı")
                    self.productList = [Products]()
                }
                DispatchQueue.main.async {
                    self.urunCollectionView.reloadData()
                }
            case .failure(let error):
                print("Hata oluştu: \(error.localizedDescription)")
            }
        }
    }
    
    func productByCategoryId(productId: Int) {
        // Seçilen kategoriye göre ürünleri filtreleyin
        productByCategoryList = productList.filter { $0.categoryId == productId }
        
        // Ürünleri yeniden yükle
        urunCollectionView.reloadData()
    }
    
    // MARK: - objc Funcs

    @objc func backImageViewTapped(){
        dismiss(animated: true)
    }

    @objc func searchImageTapped(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let urunlerVC = storyboard.instantiateViewController(withIdentifier: "searchBarVC") as? SearchBarViewController{
            
            urunlerVC.modalTransitionStyle = .coverVertical
            urunlerVC.modalPresentationStyle = .fullScreen
            
            present(urunlerVC, animated: true, completion: nil)
        }
    }
    
}

// MARK: - Extensions

extension UrunlerViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == urunCollectionView{
            return productByCategoryList.count
        }else{
            return categoryList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == urunCollectionView{
            let product = productByCategoryList[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "urunCell", for: indexPath) as! UrunCollectionViewCell
            
            cell.prepareForReuse()
            
            // Resim ve fiyat ayarlama
            
            cell.urunImageView.image = UIImage(named: "placeholderImage")
            
            cell.urunImageView.layer.cornerRadius = 15
            cell.urunImageView.clipsToBounds = true
            cell.urunImageView.layer.borderWidth = 0.2
            cell.urunImageView.layer.borderColor = UIColor.darkGray.cgColor
            
            cell.urunNameLabel.text = product.name
            cell.urunFiyatLabel.text = "\(product.price) TL"
            
            if let cachedImage = imageCache.object(forKey: product.image as NSString) {
                cell.urunImageView.image = cachedImage
            } else {
                if let url = URL(string: "https://ozerhamza.com.tr/img/\(product.image)") {
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                                // Resmi önbelleğe kaydet
                            self.imageCache.setObject(image, forKey: product.image as NSString)
                                
                            DispatchQueue.main.async {
                                    // Hücre hala görüntüleniyorsa resmi güncelle
                                if let updateCell = collectionView.cellForItem(at: indexPath) as? UrunCollectionViewCell {
                                    updateCell.urunImageView.image = image
                                }
                            }
                        }
                    }
                }
            }
            
            // Sepete ekle buton ayarlama
            cell.productId = Int16(product.id)
            cell.setProductNumContainer()
            
            return cell
        }else{
            let category = categoryList[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "urunKatCell", for: indexPath) as! UrunKategoriCollectionViewCell
            cell.categoryNameLabel.textColor = UIColor.black
            cell.categoryNameLabel.text = category.name
            cell.selectedContainer.layer.cornerRadius = 5
            cell.selectedContainer.alpha = 0
            return cell
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == urunCollectionView {
            // urunCollectionView'da seçim işlemleri
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let urunlerVC = storyboard.instantiateViewController(withIdentifier: "urunBilgiVC") as? UrunBilgiViewController {
                
                urunlerVC.product = productByCategoryList[indexPath.row]
                urunlerVC.viewControllerId = "urunlerVC"
                
                urunlerVC.modalTransitionStyle = .coverVertical
                urunlerVC.modalPresentationStyle = .fullScreen
                
                present(urunlerVC, animated: true, completion: nil)
            }
        } else {
            // Diğer collectionView için seçim işlemleri
            
            if let selectedIndexPath = selectedCategoryIndexPath {
                let previousSelectedCell = urunKategoriCollectionView.cellForItem(at: selectedIndexPath) as? UrunKategoriCollectionViewCell
                previousSelectedCell?.categoryNameLabel.textColor = UIColor.black
                previousSelectedCell?.selectedContainer.alpha = 0
            }
            
            let selectedCategory = categoryList[indexPath.row]
            let selectedCategoryId = selectedCategory.id
            print("Selected Category ID: \(selectedCategoryId)")
            productByCategoryId(productId: selectedCategoryId)
            
            print("indexPath = \(indexPath.row)")
            
            let cell = urunKategoriCollectionView.cellForItem(at: indexPath) as? UrunKategoriCollectionViewCell
            cell?.categoryNameLabel.textColor = UIColor(named: "maincolor")
            cell?.selectedContainer.alpha = 1
            
            selectedCategoryIndexPath = indexPath
        }
    }



    
}


// MARK: - Classes

class UrunCollectionViewCell:UICollectionViewCell{
    @IBOutlet weak var urunImageView: UIImageView!
    @IBOutlet weak var urunFiyatLabel: UILabel!
    @IBOutlet weak var urunNameLabel: UILabel!
    @IBOutlet weak var urunAdetContainerView: UIView!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var productNumLabel: UILabel!
    @IBOutlet weak var rightImageContainerView: UIView!
    @IBOutlet weak var rightImageView: UIImageView!
    
    let cartManager = CartManager.shared
    var productId:Int16?
    var productNum:Int16?
    
    @objc func rightImageViewTapped() {
        leftImageView.alpha = 1
        urunAdetContainerView.alpha = 1
        addProduct()
        if productNum! > 1{
            leftImageView.image = UIImage(systemName: "minus")
        }
    }
    
    @objc func leftImageViewTapped() {
        if leftImageView.image == UIImage(systemName: "trash"){
            deleteProduct()
            leftImageView.alpha = 0
            urunAdetContainerView.alpha = 0
        }else if leftImageView.image == UIImage(systemName: "minus"){
            removeProduct()
            if productNum == 1{
                leftImageView.image = UIImage(systemName: "trash")
            }
        }
    }
    
    func addProduct(){
        if productNum == 0{
            productNum! += 1
            cartManager.addProduct(productId: productId!, productNum: productNum!)
        }else{
            productNum! += 1
            cartManager.updateProduct(productId: productId!, newProductNum: productNum!)
        }
        productNumLabel.text = String(productNum!)
    }
    
    func removeProduct(){
        productNum! -= 1
        cartManager.updateProduct(productId: productId!, newProductNum: productNum!)
        productNumLabel.text = String(productNum!)
    }
    
    func deleteProduct(){
        productNum! = 0
        cartManager.deleteProduct(productId: productId!)
    }
    
    func setProductNumContainer(){
        
        let productControl = cartManager.hasProduct(withId: productId!)
        
        if productControl{
            productNum = cartManager.getProductNum(forProductId: productId!)
        }else{
            productNum = 0
        }
        
        let rightImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(rightImageViewTapped))
        rightImageView.addGestureRecognizer(rightImageTapGesture)
        rightImageView.isUserInteractionEnabled = true
        
        let leftImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(leftImageViewTapped))
        leftImageView.addGestureRecognizer(leftImageTapGesture)
        leftImageView.isUserInteractionEnabled = true
        
        urunAdetContainerView.layer.cornerRadius = 10
        
        rightImageContainerView.layer.cornerRadius = rightImageContainerView.bounds.height/2
        
        leftImageView.alpha = 0
        urunAdetContainerView.alpha = 0
        
        leftImageView.image = UIImage(systemName: "trash")
        
        if productNum == 1{
            leftImageView.alpha = 1
            urunAdetContainerView.alpha = 1
        }else if productNum! > 1{
            leftImageView.alpha = 1
            urunAdetContainerView.alpha = 1
            leftImageView.image = UIImage(systemName: "minus")
        }
        productNumLabel.text = String(productNum!)
    }
    
}

class UrunKategoriCollectionViewCell:UICollectionViewCell{
    
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var selectedContainer: UIView!
    
}
