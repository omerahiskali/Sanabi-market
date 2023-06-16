//
//  TeslimatAdresiViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 8.06.2023.
//

import UIKit

class TeslimatAdresiViewController: UIViewController, OrderAddressTableViewCellDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var orderAddressTableView: UITableView!
    @IBOutlet weak var addNewAddressImage: UIImageView!
    @IBOutlet weak var addNewAddressLabel: UILabel!
    @IBOutlet weak var cancelImage: UIImageView!
    
    // MARK: - Variables
    
    var addressList = [Address]()
    var selectedAddress:Address?
    var selectedAddressIndexPath: IndexPath?
    var totalPrice:Double?
    var totalProductPrice:Double?
    var sendPrice:Double?
    var plasticBagCount:Int?
    var cartList = [Cart]()
    var productsList = [Products]()
    
    // MARK: - View Funcs

    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderAddressTableView.delegate = self
        orderAddressTableView.dataSource = self

        // button cont
        buttonContainerView.layer.cornerRadius = 25
        buttonContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        buttonContainerView.clipsToBounds = true

        buttonContainerView.layer.shadowColor = UIColor.darkGray.cgColor
        buttonContainerView.layer.shadowOffset = CGSize(width: 0, height: -2)
        buttonContainerView.layer.shadowOpacity = 0.5
        buttonContainerView.layer.shadowRadius = 2.0
        buttonContainerView.layer.masksToBounds = false
        
        // buttons
        cancelButton.layer.cornerRadius = 10
        cancelButton.clipsToBounds = true
        cancelButton.layer.borderWidth = 1.2
        cancelButton.layer.borderColor = UIColor(named: "maincolor")?.cgColor
        
        okButton.layer.cornerRadius = 10
        okButton.clipsToBounds = true
        
        if let selectedAddress = selectedAddress,
           let index = addressList.firstIndex(of: selectedAddress) {
            let indexPath = IndexPath(row: index, section: 0)
            orderAddressTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            tableView(orderAddressTableView, didSelectRowAt: indexPath)
        }
        
        let addNewAddressTapGesture = UITapGestureRecognizer(target: self, action: #selector(addNewAddress))
        addNewAddressImage.addGestureRecognizer(addNewAddressTapGesture)
        addNewAddressLabel.addGestureRecognizer(addNewAddressTapGesture)
        addNewAddressImage.isUserInteractionEnabled = true
        addNewAddressLabel.isUserInteractionEnabled = true
        
        let cancelTapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelImageTapped))
        cancelImage.addGestureRecognizer(cancelTapGesture)
        cancelImage.isUserInteractionEnabled = true
        
    }
    
    // MARK: - Funcs
    
    func didSelectUpdateAddress(address: Address?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "adresUpdateVC") as? AdresUpdateViewController {
            
            modalVC.address = address
            
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
            
            present(modalVC, animated: true, completion: nil)
        }
    }
    
    func cancel(){
        dismiss(animated: true, completion: nil)
    }

    // MARK: - objc Funcs
    
    @objc func addNewAddress(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "addressVC") as? AddressViewController{
            
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
            
            self.present(modalVC, animated: true, completion: nil)
        }
    }
    
    @objc func cancelImageTapped(){
        cancel()
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        cancel()
    }
    
    @IBAction func okButtonAction(_ sender: Any) {
        if let selectedAddress = selectedAddress{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let modalVC = storyboard.instantiateViewController(withIdentifier: "odemeVC") as? OdemeViewController{
                
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
    
    
}

// MARK: - Extensions

extension TeslimatAdresiViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let address = addressList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderAddressCell", for: indexPath) as! OrderAddressTableViewCell
        cell.cellDidLoad()
        cell.selectedUpdateAddress = address
        cell.delegate = self
        cell.addressName.text = address.name
        cell.addressLine.text = "\(address.neighbourhood) Mah. \(address.street) No: \(address.buildingNo), \(address.districte) \(address.province)"
        cell.addressComment.text = "Adres Tarifi: \(address.adressDetails)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedIndexPath = selectedAddressIndexPath {
            let previousSelectedCell = orderAddressTableView.cellForRow(at: selectedIndexPath) as? OrderAddressTableViewCell
            // seçim bitti
            previousSelectedCell?.checkView.layer.borderColor = UIColor.gray.cgColor
            previousSelectedCell?.checkView.backgroundColor = UIColor.systemGray5
            
        }
        
        selectedAddress = addressList[indexPath.row]
        
        let cell = orderAddressTableView.cellForRow(at: indexPath) as? OrderAddressTableViewCell
        // seçildi
        cell?.checkView.layer.borderColor = UIColor(named: "maincolor")?.cgColor
        cell?.checkView.backgroundColor = UIColor.white
        
        selectedAddressIndexPath = indexPath
    }
    
}

 // MARK: - Classes

class OrderAddressTableViewCell: UITableViewCell{
    
    @IBOutlet weak var checkView: UIView!
    @IBOutlet weak var addressName: UILabel!
    @IBOutlet weak var addressLine: UILabel!
    @IBOutlet weak var addressComment: UILabel!
    @IBOutlet weak var updateImage: UIImageView!
    
    var selectedUpdateAddress:Address?
    weak var delegate: OrderAddressTableViewCellDelegate?
    
    func cellDidLoad(){
        
        checkView.layer.cornerRadius = checkView.frame.height / 2
        checkView.clipsToBounds = true
        
        checkView.layer.borderWidth = 3
        checkView.layer.borderColor = UIColor.gray.cgColor
        
        let updateAddressTapGesture = UITapGestureRecognizer(target: self, action: #selector(updateImageTapped))
        updateImage.addGestureRecognizer(updateAddressTapGesture)
        updateImage.isUserInteractionEnabled = true

    }
    
    @objc func updateImageTapped(){
        print("basıldı")
        delegate?.didSelectUpdateAddress(address: selectedUpdateAddress)
    }
    
}

// MARK: - Protocols

protocol OrderAddressTableViewCellDelegate: AnyObject {
    func didSelectUpdateAddress(address: Address?)
}
