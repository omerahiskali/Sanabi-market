//
//  OncekiSiparisViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 11.06.2023.
//

import UIKit
import Alamofire

class OncekiSiparisViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var previousOrdersTableView: UITableView!
    @IBOutlet weak var cancelImage: UIImageView!
    
    // MARK: - Variables
    
    var orderList = [OrderProductModelItem]()
    let d = UserDefaults.standard
    
    // MARK: - View Funcs

    override func viewDidLoad() {
        super.viewDidLoad()

        previousOrdersTableView.delegate = self
        previousOrdersTableView.dataSource = self
        
        let id = d.string(forKey: "id")

        if let id = id{
            takeOrders(id: id)
        }
        
        let cancelImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelImageViewTapped))
        cancelImage.addGestureRecognizer(cancelImageTapGesture)
        cancelImage.isUserInteractionEnabled = true

    }
    
    // MARK: - Funcs
    
    func takeOrders(id: String) {
        let url = "https://ozerhamza.xyz/api/Order/\(id)"
        
        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let orderProducts = try decoder.decode([OrderProductModelItem].self, from: data)
                    self.orderList = orderProducts
                    self.previousOrdersTableView.reloadData()
                } catch {
                    print("JSON dönüşüm hatası: \(error)")
                }
            case .failure(let error):
                print("API isteği başarısız oldu: \(error)")
            }
        }
    }
    
    // MARK: - objc Funcs
    
    @objc func cancelImageViewTapped(){
        dismiss(animated: true)
    }
}

// MARK: - Extensions

extension OncekiSiparisViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let order = orderList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "previousOrderCell", for: indexPath) as! PreviousOrdersTableViewCell
        
        cell.containerView.layer.cornerRadius = 10
        cell.containerView.clipsToBounds = true

        cell.containerView.layer.shadowColor = UIColor.darkGray.cgColor
        cell.containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.containerView.layer.shadowOpacity = 0.5
        cell.containerView.layer.shadowRadius = 2.0
        cell.containerView.layer.masksToBounds = false
        
        cell.createDateLabel.text = order.createDate
        cell.priceLabel.text = String(order.amount)
        
        var detailText = ""
        
        for product in order._Products{
            if detailText == ""{
                detailText += "\(product.productQuantity)x \(product.product.name)"
            }else{
                detailText += ", \(product.productQuantity)x \(product.product.name)"
            }
        }
        
        cell.detailLabel.text = detailText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let order = orderList[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "oncekiSiparisDetayVC") as? OncekiSiparisDetayViewController {
            
            modalVC.order = order
            
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
            
            present(modalVC, animated: true, completion: nil)
        }
    }
    
}

// MARK: - Classes

class PreviousOrdersTableViewCell:UITableViewCell{
    
    @IBOutlet weak var createDateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
}
