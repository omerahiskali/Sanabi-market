//
//  SepetViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 6.06.2023.
//

import UIKit
import Alamofire

class SepetViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var suggestionCollectionView: UICollectionView!
    @IBOutlet weak var cartTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendTimeContainerView: UIView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var totalProductPriceLabel: UILabel!
    @IBOutlet weak var sendPriceLabel: UILabel!
    @IBOutlet weak var plasticBagPriceLabel: UILabel!
    @IBOutlet weak var sendPriceTextLabel: UILabel!
    @IBOutlet weak var plasticBagPriceTextLabel: UILabel!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var cancelImage: UIImageView!
    
    
    // MARK: - Variables
    
    let cartManager = CartManager.shared
    var cartList = [Cart]()
    var productsList = [Products]()
    var suggestProductList = [Products]()
    let imageCache = NSCache<NSString, UIImage>()
    var totalPrice = 0.0
    var totalProductPrice = 0.0
    var sendPrice = 14.99
    var plasticBagPrice = 0.25
    
    // MARK: - View Funcs

    override func viewDidLoad() {
        super.viewDidLoad()

        cartList = cartManager.getAllProducts() ?? [Cart]()
        
        takeProducts()
        
        cartTableView.delegate = self
        cartTableView.dataSource = self
        
        suggestionCollectionView.delegate = self
        suggestionCollectionView.dataSource = self
        
        setScrollViewHeight()
        
        sendTimeContainerView.layer.cornerRadius = 10
        sendTimeContainerView.clipsToBounds = true
        sendTimeContainerView.layer.borderWidth = 0.2
        sendTimeContainerView.layer.borderColor = UIColor.darkGray.cgColor
        
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.isEnabled = false
        
        buttonContainerView.layer.cornerRadius = 25
        buttonContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        buttonContainerView.clipsToBounds = true

        buttonContainerView.layer.shadowColor = UIColor.black.cgColor
        buttonContainerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        buttonContainerView.layer.shadowOpacity = 0.8
        buttonContainerView.layer.shadowRadius = 4.0
        buttonContainerView.layer.masksToBounds = false
        
        let cancelImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelImageViewTapped))
        cancelImage.addGestureRecognizer(cancelImageTapGesture)
        cancelImage.isUserInteractionEnabled = true
        
    }

    // MARK: - Funcs
    
    func setScrollViewHeight(){
        scrollViewContainerHeightConstraint.constant = scrollViewContainerHeightConstraint.constant + CGFloat(cartList.count) * 80
    }
    
    func setPrices(){
        totalProductPrice = calculateTotalPrice()
        if totalProductPrice > 299.99{
            sendPrice = 0
            sendPriceTextLabel.text = "Gönderim Ücreti (Ücretsiz)"
        }else{
            sendPrice = 14.99
            sendPriceTextLabel.text = "Gönderim Ücreti"
        }
        let plasticBagCount = calculatePlasticBagCount()
        plasticBagPrice = Double(plasticBagCount) * 0.25
        
        let number = totalProductPrice + sendPrice + plasticBagPrice
        let roundedNumber = String(format: "%.2f", number)
        totalPrice = Double(roundedNumber)!
        
        totalPriceLabel.text = "\(totalPrice) TL"
        totalProductPriceLabel.text = "\(totalProductPrice) TL"
        sendPriceLabel.text = "\(sendPrice) TL"
        plasticBagPriceLabel.text = "\(plasticBagPrice) TL"
        
        plasticBagPriceTextLabel.text = "Poşet Ücreti (\(plasticBagCount)x)"
    }
    
    func takeProducts() {
        let url = "https://ozerhamza.xyz/api/Products"
        
        AF.request(url).responseDecodable(of: ProductList.self) { response in
            switch response.result {
            case .success(let value):
                if let data = value.data{
                    self.productsList = data
                    print("productList count : \(self.productsList.count)")
                    self.button.isEnabled = true
                    self.setPrices()
                    self.takeSuggestProducts()
                } else {
                    print("Hatalı API yanıtı")
                    self.productsList = [Products]()
                }
                DispatchQueue.main.async {
                    self.cartTableView.reloadData()
                    self.suggestionCollectionView.reloadData()
                }
            case .failure(let error):
                print("Hata oluştu: \(error.localizedDescription)")
            }
        }
    }
    
    func takeProductOnCart(productId: Int) -> Products? {
        if let cart = cartList.first(where: { $0.productId == productId }) {
            if let product = productsList.first(where: { $0.id == cart.productId }) {
                return product
            }
        }
        return nil
    }
    
    func calculateTotalPrice() -> Double {
        var totalPrice: Double = 0.0
        
        for cartProduct in cartList {
            if let product = productsList.first(where: { $0.id == cartProduct.productId }) {
                let price = product.price
                let quantity = Double(cartProduct.productNum)
                let productTotalPrice = price * quantity
                totalPrice += productTotalPrice
            }
        }
        
        let roundedPrice = String(format: "%.2f", totalPrice)
        
        return Double(roundedPrice)!
    }

    func calculatePlasticBagCount() -> Int {
        let totalQuantity = cartList.reduce(0) { $0 + $1.productNum }
        let bagCount = totalQuantity / 8 + (totalQuantity % 8 == 0 ? 0 : 1)
        return Int(bagCount)
    }
    
    func takeSuggestProducts() {
        if productsList.count >= 6 {
            var randomIndices = Set<Int>()
            
            while randomIndices.count < 6 {
                let randomIndex = Int.random(in: 0..<productsList.count)
                randomIndices.insert(randomIndex)
            }
            
            for index in randomIndices {
                suggestProductList.append(productsList[index])
            }
        }
    }
    
    // MARK: - objc Funcs
    
    @objc func cancelImageViewTapped(){
        dismiss(animated: true)
    }

    // MARK: - Actions
    
    @IBAction func buttonAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "odemeVC") as? OdemeViewController {
            
            modalVC.plasticBagCount = calculatePlasticBagCount()
            modalVC.totalPrice = totalPrice
            modalVC.totalProductPrice = totalProductPrice
            modalVC.sendPrice = sendPrice
            
            modalVC.cartList = cartList
            modalVC.productsList = productsList
            
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
            
            present(modalVC, animated: true, completion: nil)
        }
    }
    
}

// MARK: - Extensions

extension SepetViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cartProduct = cartList[indexPath.row]
        let productId = cartProduct.productId
        
        if let product = takeProductOnCart(productId: Int(productId)) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sepetCell", for: indexPath) as! SepetTableViewCell
            
            cell.prepareForReuse()
            
            cell.productImage.image = UIImage(named: "placeholderImage")
            
            cell.productImage.layer.cornerRadius = 10
            cell.productImage.clipsToBounds = true
            cell.productImage.layer.borderWidth = 0.2
            cell.productImage.layer.borderColor = UIColor.darkGray.cgColor
            
            cell.productId = Int16(product.id)
            cell.setProductNumContainer(sepetViewController: self)
            
            cell.productNameCell.text = product.name
            
            let price = cell.takeTotalPrice(productPrice: product.price)
            
            cell.productPriceLabel.text = "\(price) TL"
            
            if let cachedImage = imageCache.object(forKey: product.image as NSString) {
                cell.productImage.image = cachedImage
            } else {
                if let url = URL(string: "https://ozerhamza.com.tr/img/\(product.image)") {
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                            self.imageCache.setObject(image, forKey: product.image as NSString)
                            
                            DispatchQueue.main.async {
                                if let updateCell = tableView.cellForRow(at: indexPath) as? SepetTableViewCell {
                                    updateCell.productImage.image = image
                                }
                            }
                        }
                    }
                }
            }
            
            return cell
        } else {
            // Veri henüz yoksa veya hatalıysa geçici bir "yükleniyor" hücresi döndür
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingTableViewCell
            cell.loadingIndicator.startAnimating()
            return cell
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cartTableViewHeightConstraint.constant = CGFloat(cartList.count) * 80
    }
    
}

extension SepetViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return suggestProductList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let product = suggestProductList[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "suggestionCell", for: indexPath) as! SuggestionCollectionViewCell
        cell.prepareForReuse()
        
        cell.productImageView.image = UIImage(named: "placeholderImage")
        
        cell.productImageView.layer.cornerRadius = 10
        cell.productImageView.clipsToBounds = true
        cell.productImageView.layer.borderWidth = 0.2
        cell.productImageView.layer.borderColor = UIColor.darkGray.cgColor
        
        cell.productPriceLabel.text = "\(product.price) TL"
        cell.productNameLabel.text = product.name
        
        if let cachedImage = imageCache.object(forKey: product.image as NSString) {
            cell.productImageView.image = cachedImage
        } else {
            if let url = URL(string: "https://ozerhamza.com.tr/img/\(product.image)") {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        self.imageCache.setObject(image, forKey: product.image as NSString)
                        
                        DispatchQueue.main.async {
                            if let updateCell = collectionView.cellForItem(at: indexPath) as? SuggestionCollectionViewCell {
                                updateCell.productImageView.image = image
                            }
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let urunlerVC = storyboard.instantiateViewController(withIdentifier: "urunBilgiVC") as? UrunBilgiViewController {
            
            urunlerVC.product = suggestProductList[indexPath.row]
            urunlerVC.viewControllerId = "sepetVC"
            
            urunlerVC.modalTransitionStyle = .coverVertical
            urunlerVC.modalPresentationStyle = .fullScreen
            
            present(urunlerVC, animated: true, completion: nil)
        }
    }
}

// MARK: - Classes

class SepetTableViewCell: UITableViewCell{
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productNameCell: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productNumContainerView: UIView!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var productNumLabel: UILabel!
    @IBOutlet weak var rightImageContainer: UIView!
    @IBOutlet weak var rightImageView: UIImageView!
    
    let cartManager = CartManager.shared
    var productId:Int16?
    var productNum:Int16?
    weak var sepetViewController: SepetViewController?
    
    func setProductNumContainer(sepetViewController: SepetViewController){
        
        self.sepetViewController = sepetViewController
        
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
        
        productNumContainerView.layer.cornerRadius = 10
        
        rightImageContainer.layer.cornerRadius = rightImageContainer.bounds.height/2
        
        leftImageView.image = UIImage(systemName: "trash")
        
        if productNum! > 1{
            leftImageView.image = UIImage(systemName: "minus")
        }
        productNumLabel.text = String(productNum!)
    }
    
    @objc func rightImageViewTapped() {
        addProduct()
        if productNum! > 1{
            leftImageView.image = UIImage(systemName: "minus")
        }
    }
    
    @objc func leftImageViewTapped() {
        if leftImageView.image == UIImage(systemName: "trash"){
            deleteProduct()
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
        if let sepetVC = sepetViewController{
            sepetVC.cartList = cartManager.getAllProducts() ?? [Cart]()
            sepetVC.setPrices()
            sepetVC.cartTableView.reloadData()
        }
    }
    
    func removeProduct(){
        productNum! -= 1
        cartManager.updateProduct(productId: productId!, newProductNum: productNum!)
        productNumLabel.text = String(productNum!)
        if let sepetVC = sepetViewController{
            sepetVC.cartList = cartManager.getAllProducts() ?? [Cart]()
            sepetVC.setPrices()
            sepetVC.cartTableView.reloadData()
        }
    }
    
    func deleteProduct(){
        productNum! = 0
        cartManager.deleteProduct(productId: productId!)
        if let sepetVC = sepetViewController{
            sepetVC.cartList = cartManager.getAllProducts() ?? [Cart]()
            sepetVC.setPrices()
            sepetVC.cartTableView.reloadData()
            sepetVC.setScrollViewHeight()
        }
    }
    
    func takeTotalPrice(productPrice:Double)->Double{
        return productPrice * Double(productNum!)
    }
}

class LoadingTableViewCell: UITableViewCell{
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
}


class SuggestionCollectionViewCell: UICollectionViewCell{
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    
}
