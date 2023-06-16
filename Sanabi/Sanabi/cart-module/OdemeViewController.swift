//
//  OdemeViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 8.06.2023.
//

import UIKit
import Alamofire
import CoreLocation

class OdemeViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var addressContainerView: UIView!
    @IBOutlet weak var addressCommentContainerView: UIView!
    @IBOutlet weak var contaclessDeliveryContainerView: UIView!
    @IBOutlet weak var paymentTypeContainerView: UIView!
    @IBOutlet weak var orderSummaryContainerView: UIView!
    @IBOutlet weak var priceSummaryContainerView: UIView!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var firstAddressLine: UILabel!
    @IBOutlet weak var secondAddressLine: UILabel!
    @IBOutlet weak var addressCommentLine: UILabel!
    
    @IBOutlet weak var kapidaKrediCheckView: UIView!
    @IBOutlet weak var kapidaNakitCheckView: UIView!
    
    @IBOutlet weak var paymentTypeTotalPriceLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var sendPriceLabel: UILabel!
    @IBOutlet weak var sendPriceTextLabel: UILabel!
    @IBOutlet weak var plasticBagPriceLabel: UILabel!
    @IBOutlet weak var plasticBagPriceTextLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    @IBOutlet weak var orderSummaryTableView: UITableView!
    
    @IBOutlet weak var scrollViewContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cartTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var updateAddressImage: UIImageView!
    @IBOutlet weak var addAddressImage: UIImageView!
    
    @IBOutlet weak var cancelImage: UIImageView!
    
    // MARK: - Sturcts

    struct Product: Codable {
        let productId: Int
        let productQuantity: Int
    }
    
    // MARK: - Variables
    
    var totalPrice:Double?
    var totalProductPrice:Double?
    var sendPrice:Double?
    var plasticBagPrice = 0.25
    var plasticBagCount:Int?
    var cartList = [Cart]()
    var productsList = [Products]()
    var addressList = [Address]()
    var selectedAddress:Address?
    var paymentId = 1
    let d = UserDefaults.standard
    let headers: HTTPHeaders = [
        "Content-Type": "application/json"
    ]
    var cartProductList = [Product]()
    let cartManager = CartManager.shared
    
    // MARK: - View Funcs

    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstAddressLine.text = "Kayıtlı teslimat adresiniz yok"
        secondAddressLine.text = "Kayıtlı teslimat adresiniz yok"
        addressCommentLine.text = "Adres tarifi ekleyiniz"
        addressCommentLine.textColor = UIColor(named: "maincolor")
        
        scrollViewContainerHeightConstraint.constant = scrollViewContainerHeightConstraint.constant + CGFloat(cartList.count) * 50
        cartTableViewHeightConstraint.constant = cartTableViewHeightConstraint.constant + CGFloat(cartList.count - 1) * 50
        
        orderSummaryTableView.delegate = self
        orderSummaryTableView.dataSource = self

        setViews()
        setPrices()
        
        let id = d.string(forKey: "id")
        
        if let selectedAddress = selectedAddress{
            firstAddressLine.text = "\(selectedAddress.neighbourhood) Mah. \(selectedAddress.street) No: \(selectedAddress.buildingNo)"
            secondAddressLine.text = "\(selectedAddress.districte) \(selectedAddress.province) \(selectedAddress.postCode)"
            addressCommentLine.text = "\(selectedAddress.adressDetails)"
            self.addressCommentLine.textColor = UIColor.black
        }else{
            takeAddresses(for: id!)
        }
        
        checkPayment(id: 1)
        
        let kapidaKrediTapGesture = UITapGestureRecognizer(target: self, action: #selector(kapidaKrediViewTapped))
        kapidaKrediCheckView.addGestureRecognizer(kapidaKrediTapGesture)
        kapidaKrediCheckView.isUserInteractionEnabled = true
        
        let kapidaNakitTapGesture = UITapGestureRecognizer(target: self, action: #selector(kapidaNakitViewTapped))
        kapidaNakitCheckView.addGestureRecognizer(kapidaNakitTapGesture)
        kapidaNakitCheckView.isUserInteractionEnabled = true
        
        let addAddressTapGesture = UITapGestureRecognizer(target: self, action: #selector(addAddressViewTapped))
        addAddressImage.addGestureRecognizer(addAddressTapGesture)
        addAddressImage.isUserInteractionEnabled = true
        
        let updateAddressTapGesture = UITapGestureRecognizer(target: self, action: #selector(updateAddressViewTapped))
        updateAddressImage.addGestureRecognizer(updateAddressTapGesture)
        updateAddressImage.isUserInteractionEnabled = true
        
        let cancelImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelImageViewTapped))
        cancelImage.addGestureRecognizer(cancelImageTapGesture)
        cancelImage.isUserInteractionEnabled = true

    }
    
    // MARK: - Funcs
    
    func takeAddresses(for id: String) {
        let url = "https://ozerhamza.xyz/api/Adress/GetSingleAdressByIdCustomerAdress/\(id)"
        
        AF.request(url).responseDecodable(of: AddressList.self) { response in
            switch response.result {
            case .success(let value):
                if let data = value.data{
                    // başarılı
                    self.addressList = data
                    self.findAddress(addressList: self.addressList)
                } else {
                    print("Hatalı API yanıtı")
                    self.addressList = [Address]()
                }
            case .failure(let error):
                print("Hata oluştu: \(error.localizedDescription)")
            }
        }
    }
    
    func findAddress(addressList:[Address]){
        getAddress { address in
            if let address = address {
                for ca in addressList{
                    if ca.province == address.administrativeArea{
                        self.selectedAddress = ca
                        self.firstAddressLine.text = "\(self.selectedAddress!.neighbourhood) Mah. \(self.selectedAddress!.street) No: \(self.selectedAddress!.buildingNo)"
                        self.secondAddressLine.text = "\(self.selectedAddress!.districte) \(self.selectedAddress!.province) \(self.selectedAddress!.postCode)"
                        self.addressCommentLine.text = "\(self.selectedAddress!.adressDetails)"
                        self.addressCommentLine.textColor = UIColor.black
                        break
                    }else{
                        self.firstAddressLine.text = "Kayıtlı teslimat adresiniz yok"
                        self.secondAddressLine.text = "Kayıtlı teslimat adresiniz yok"
                        self.addressCommentLine.text = "Adres tarifi ekleyiniz"
                        self.addressCommentLine.textColor = UIColor(named: "maincolor")
                    }
                }
            } else {
                print("Adres alınamadı.")
                self.firstAddressLine.text = "Kayıtlı teslimat adresiniz yok"
                self.secondAddressLine.text = "Kayıtlı teslimat adresiniz yok"
                self.addressCommentLine.text = "Adres tarifi ekleyiniz"
                self.addressCommentLine.textColor = UIColor(named: "maincolor")
            }
        }
    }
    
    func getAddress(completion: @escaping (CLPlacemark?) -> Void) {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()

        guard let currentLocation = locationManager.location else {
            print("Konum bilgisi alınamadı.")
            completion(nil)
            return
        }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            if let error = error {
                print("Hata: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let placemark = placemarks?.first {
                completion(placemark)
            }
        }
    }
    
    func checkPayment(id:Int){
        if id == 1 {
            kapidaKrediCheckView.layer.borderColor = UIColor(named: "maincolor")?.cgColor
            kapidaKrediCheckView.backgroundColor = UIColor.white
            kapidaNakitCheckView.layer.borderColor = UIColor.gray.cgColor
            kapidaNakitCheckView.backgroundColor = UIColor.systemGray5
            paymentId = 1
        }else if id == 2{
            kapidaNakitCheckView.layer.borderColor = UIColor(named: "maincolor")?.cgColor
            kapidaNakitCheckView.backgroundColor = UIColor.white
            kapidaKrediCheckView.layer.borderColor = UIColor.gray.cgColor
            kapidaKrediCheckView.backgroundColor = UIColor.systemGray5
            paymentId = 2
        }
    }
    
    func setPrices(){
        if let totalPrice = totalPrice, let totalProductPrice = totalProductPrice, let sendPrice = sendPrice, let plasticBagCount = plasticBagCount{
            paymentTypeTotalPriceLabel.text = "\(totalPrice) TL"
            productPriceLabel.text = "\(totalProductPrice) TL"
            sendPriceLabel.text = "\(sendPrice) TL"
            if sendPrice == 14.99{
                sendPriceTextLabel.text = "Gönderim Ücreti"
            }else{
                sendPriceTextLabel.text = "Gönderim Ücreti (Ücretsiz)"
            }
            let totalPlasticBagPrice = plasticBagPrice * Double(plasticBagCount)
            plasticBagPriceLabel.text = "\(totalPlasticBagPrice) TL"
            plasticBagPriceTextLabel.text = "Poşet Ücreti (\(plasticBagCount)x)"
            totalPriceLabel.text = "\(totalPrice) TL"
        }
        
    }
    
    func setViews(){
        // adress
        addressContainerView.layer.cornerRadius = 10
        addressContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        addressContainerView.clipsToBounds = true

        addressContainerView.layer.shadowColor = UIColor.darkGray.cgColor
        addressContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        addressContainerView.layer.shadowOpacity = 0.5
        addressContainerView.layer.shadowRadius = 2.0
        addressContainerView.layer.masksToBounds = false
        
        // address comment
        addressCommentContainerView.layer.shadowColor = UIColor.darkGray.cgColor
        addressCommentContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        addressCommentContainerView.layer.shadowOpacity = 0.5
        addressCommentContainerView.layer.shadowRadius = 2.0
        addressCommentContainerView.layer.masksToBounds = false
        
        // contacless delivery
        contaclessDeliveryContainerView.layer.cornerRadius = 10
        contaclessDeliveryContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        contaclessDeliveryContainerView.clipsToBounds = true

        contaclessDeliveryContainerView.layer.shadowColor = UIColor.darkGray.cgColor
        contaclessDeliveryContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        contaclessDeliveryContainerView.layer.shadowOpacity = 0.5
        contaclessDeliveryContainerView.layer.shadowRadius = 2.0
        contaclessDeliveryContainerView.layer.masksToBounds = false
        
        // payment type
        paymentTypeContainerView.layer.cornerRadius = 10
        paymentTypeContainerView.clipsToBounds = true

        paymentTypeContainerView.layer.shadowColor = UIColor.darkGray.cgColor
        paymentTypeContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        paymentTypeContainerView.layer.shadowOpacity = 0.5
        paymentTypeContainerView.layer.shadowRadius = 2.0
        paymentTypeContainerView.layer.masksToBounds = false
        
        // payment check boxes
        kapidaKrediCheckView.layer.cornerRadius = kapidaKrediCheckView.frame.height / 2
        kapidaNakitCheckView.layer.cornerRadius = kapidaNakitCheckView.frame.height / 2
        kapidaKrediCheckView.clipsToBounds = true
        kapidaNakitCheckView.clipsToBounds = true
        
        kapidaKrediCheckView.layer.borderWidth = 3
        kapidaKrediCheckView.layer.borderColor = UIColor.gray.cgColor
        
        kapidaNakitCheckView.layer.borderWidth = 3
        kapidaNakitCheckView.layer.borderColor = UIColor.gray.cgColor
        
        // order summary
        orderSummaryContainerView.layer.cornerRadius = 10
        orderSummaryContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        orderSummaryContainerView.clipsToBounds = true

        orderSummaryContainerView.layer.shadowColor = UIColor.darkGray.cgColor
        orderSummaryContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        orderSummaryContainerView.layer.shadowOpacity = 0.5
        orderSummaryContainerView.layer.shadowRadius = 2.0
        orderSummaryContainerView.layer.masksToBounds = false
        
        // price summary
        priceSummaryContainerView.layer.cornerRadius = 10
        priceSummaryContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        priceSummaryContainerView.clipsToBounds = true

        priceSummaryContainerView.layer.shadowColor = UIColor.darkGray.cgColor
        priceSummaryContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        priceSummaryContainerView.layer.shadowOpacity = 0.5
        priceSummaryContainerView.layer.shadowRadius = 2.0
        priceSummaryContainerView.layer.masksToBounds = false
        
        // button cont
        buttonContainerView.layer.cornerRadius = 25
        buttonContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        buttonContainerView.clipsToBounds = true

        buttonContainerView.layer.shadowColor = UIColor.darkGray.cgColor
        buttonContainerView.layer.shadowOffset = CGSize(width: 0, height: -2)
        buttonContainerView.layer.shadowOpacity = 0.5
        buttonContainerView.layer.shadowRadius = 2.0
        buttonContainerView.layer.masksToBounds = false
        
        // button
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
    }
    
    func takeProductOnCart(productId: Int) -> Products? {
        if let cart = cartList.first(where: { $0.productId == productId }) {
            if let product = productsList.first(where: { $0.id == cart.productId }) {
                return product
            }
        }
        return nil
    }
    
    func createOrder(){
        print("create order girildi")
        for cp in cartList{
            let product = Product(productId: Int(cp.productId), productQuantity: Int(cp.productNum))
            cartProductList.append(product)
        }
        
        for n in cartProductList{
            print(n.productId)
            print(n.productQuantity)
        }
        
        let customerId = d.string(forKey: "id")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)

        addOrder(createDate: formattedDate, adressId: selectedAddress!.id, paymentTypeId: paymentId, orderStatusId: 1, customerId: Int(customerId!)!, amount: totalPrice!, products: cartProductList)
        
    }

    func addOrder(createDate: String, adressId: Int, paymentTypeId: Int, orderStatusId: Int, customerId: Int, amount: Double, products: [Product]) {
        let url = "https://ozerhamza.xyz/api/Order"
        
        let parameters: [String: Any] = [
            "createDate": createDate,
            "adressId": adressId,
            "paymentTypeId": paymentTypeId,
            "orderStatusId": orderStatusId,
            "customerId": customerId,
            "amount": amount,
            "_Products": products.map { product in
                return [
                    "productId": product.productId,
                    "productQuantity": product.productQuantity
                ]
            }
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
            
            if let data = response.data{
                do{
                    // API Kayıt başarılı
                    let cevap = try JSONSerialization.jsonObject(with: data)
                    print(cevap)
                    self.cartManager.deleteCart()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let modalVC = storyboard.instantiateViewController(withIdentifier: "homePageVC") as? HomePageViewController {
                        
                        modalVC.modalTransitionStyle = .coverVertical
                        modalVC.modalPresentationStyle = .fullScreen
                        
                        self.present(modalVC, animated: true, completion: nil)
                    }
                }catch{
                    // API Kayıt başarısız
                    print(error.localizedDescription)
                    self.button.isEnabled = true
                
                }
            }
        }
    }



    
    // MARK: - objc Funcs
    
    @objc func kapidaKrediViewTapped() {
        checkPayment(id: 1)
    }

    @objc func kapidaNakitViewTapped() {
        checkPayment(id: 2)
    }
    
    @objc func addAddressViewTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "teslimatAdresVC") as? TeslimatAdresiViewController {
            
            modalVC.addressList = addressList
            modalVC.selectedAddress = selectedAddress
            
            modalVC.plasticBagCount = plasticBagCount
            modalVC.totalPrice = totalPrice
            modalVC.totalProductPrice = totalProductPrice
            modalVC.sendPrice = sendPrice
            modalVC.cartList = cartList
            modalVC.productsList = productsList
            
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
            
            self.present(modalVC, animated: true, completion: nil)
        }
    }
    
    @objc func updateAddressViewTapped() {
        if let selectedAddress = selectedAddress{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let modalVC = storyboard.instantiateViewController(withIdentifier: "adresUpdateVC") as? AdresUpdateViewController {
                
                modalVC.address = selectedAddress
                
                modalVC.modalTransitionStyle = .coverVertical
                modalVC.modalPresentationStyle = .fullScreen
                
                self.present(modalVC, animated: true, completion: nil)
            }
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let modalVC = storyboard.instantiateViewController(withIdentifier: "teslimatAdresVC") as? TeslimatAdresiViewController {
                
                modalVC.addressList = addressList
                modalVC.selectedAddress = selectedAddress
                
                modalVC.plasticBagCount = plasticBagCount
                modalVC.totalPrice = totalPrice
                modalVC.totalProductPrice = totalProductPrice
                modalVC.sendPrice = sendPrice
                modalVC.cartList = cartList
                modalVC.productsList = productsList
                
                modalVC.modalTransitionStyle = .coverVertical
                modalVC.modalPresentationStyle = .fullScreen
                
                self.present(modalVC, animated: true, completion: nil)
            }
        }
    }

    @objc func cancelImageViewTapped(){
        dismiss(animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func buttonAction(_ sender: Any) {
        button.isEnabled = false
        print("buton basıldı")
        if selectedAddress != nil && totalPrice != nil {
            createOrder()
        }else{
            print("HATA: Button Action")
            button.isEnabled = true
            let alertController = UIAlertController(title: "Hata", message: "Teslimat için bir adres seçiniz.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - Extensions

extension OdemeViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cartProduct = cartList[indexPath.row]
        let productId = cartProduct.productId
        let product = takeProductOnCart(productId: Int(productId))
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderSummaryCell", for: indexPath) as! OrderSummaryTableViewCell
        
        cell.productName.text = "\(cartProduct.productNum)x \(product!.name)"
        
        let totalProductPrice = Double(cartProduct.productNum) * product!.price
        cell.productPrice.text = "\(totalProductPrice) TL"
        
        return cell
    }
    
}

// MARK: - Classes

class OrderSummaryTableViewCell: UITableViewCell{
    
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    
}
