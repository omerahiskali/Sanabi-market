//
//  OncekiSiparisDetayViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 11.06.2023.
//

import UIKit
import Alamofire

class OncekiSiparisDetayViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var marketLocationLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var previousOrderDetailTableView: UITableView!
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var cancelImage: UIImageView!
    
    // MARK: - Variables
    
    var order:OrderProductModelItem?
    var address:Address?
    var productList = [Product]()
    let cartManager = CartManager.shared
    var cart = [Cart]()
    
    // MARK: - View Funcs

    override func viewDidLoad() {
        super.viewDidLoad()
        
        takeProductsOnList()
        
        if let order = order{
            takeAddressById(for: String(order.adressId))
        }
        
        previousOrderDetailTableView.delegate = self
        previousOrderDetailTableView.dataSource = self

        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.isEnabled = false
        
        buttonContainer.layer.cornerRadius = 25
        buttonContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        buttonContainer.clipsToBounds = true

        buttonContainer.layer.shadowColor = UIColor.black.cgColor
        buttonContainer.layer.shadowOffset = CGSize(width: 0, height: 3)
        buttonContainer.layer.shadowOpacity = 0.8
        buttonContainer.layer.shadowRadius = 4.0
        buttonContainer.layer.masksToBounds = false
        
        let cancelImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelImageViewTapped))
        cancelImage.addGestureRecognizer(cancelImageTapGesture)
        cancelImage.isUserInteractionEnabled = true
        
    }

    // MARK: - Funcs

    func setLabels(){
        if let order = order, let address = address{
            dateLabel.text = "\(order.createDate) tarihinde sipariş verildi"
            marketLocationLabel.text = "Sanabi Market; \(address.districte)"
            addressLabel.text = "\(address.neighbourhood) Mah. \(address.street) No: \(address.buildingNo) \(address.districte) \(address.province)"
            totalPriceLabel.text = "\(order.amount) TL"
        }
    }
    
    func takeAddressById(for id: String) {
        let url = "https://ozerhamza.xyz/api/Adress/\(id)"
        
        AF.request(url).responseDecodable(of: AddressData.self) { response in
            switch response.result {
            case .success(let value):
                if let data = value.data{
                    self.address = data
                    self.button.isEnabled = true
                    self.setLabels()
                } else {
                    print("Hatalı API yanıtı")
                }
            case .failure(let error):
                print("Hata oluştu: \(error.localizedDescription)")
            }
        }
    }
    
    func takeProductsOnList(){
        if let order = order{
            for product in order._Products{
                productList.append(product)
            }
            self.previousOrderDetailTableView.reloadData()
        }

    }
    
    func repeatOrder(){
        if let order = order{
            
            for product in productList{
                cartManager.addProduct(productId: Int16(product.product.id), productNum: Int16(product.productQuantity))
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let urunlerVC = storyboard.instantiateViewController(withIdentifier: "sepetVC") as? SepetViewController {
                
                urunlerVC.modalTransitionStyle = .coverVertical
                urunlerVC.modalPresentationStyle = .fullScreen
                
                present(urunlerVC, animated: true, completion: nil)
            }
            
        }
    }
    
    func cartControl(){
        cart = cartManager.getAllProducts() ?? [Cart]()
        if cart.isEmpty{

        }else{
            let alertController = UIAlertController(title: "Sepetinizde başka ürünler var", message: "Siparişi tekrarlarsanız sepetinizdeki ürünler silinecek.", preferredStyle: .alert)

            let cancelAction = UIAlertAction(title: "İptal", style: .destructive) { _ in

            }
            
            let confirmAction = UIAlertAction(title: "Tamam", style: .default) { _ in
                self.cartManager.deleteCart()
                self.repeatOrder()
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)
            
            // Alert dialogını göster
            present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - objc Funcs
    
    @objc func cancelImageViewTapped(){
        dismiss(animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func buttonAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Siparişi Tekrarlamak İstiyor musunuz?", message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "İptal", style: .destructive) { _ in

        }
        
        let confirmAction = UIAlertAction(title: "Evet", style: .default) { _ in
            self.cartControl()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        // Alert dialogını göster
        present(alertController, animated: true, completion: nil)

    }
    
}

// MARK: - Extensions

extension OncekiSiparisDetayViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = productList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "previousOrderDetailCell", for: indexPath) as! PreviousOrderDetailTableViewCell
        
        cell.productNameLabel.text = "\(product.productQuantity)x \(product.product.name)"
        
        let totalPrice = Double(product.productQuantity) * product.product.price
        let roundedTotalPrice = String(format: "%.2f", totalPrice)
        cell.totalPriceLabel.text = "\(roundedTotalPrice) TL"
        
        return cell
    }
    
    
}

// MARK: - Classes

class PreviousOrderDetailTableViewCell: UITableViewCell{
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
}
