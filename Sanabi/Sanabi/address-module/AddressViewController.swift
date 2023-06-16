//
//  AddressViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 27.05.2023.
//

import UIKit
import Alamofire

class AddressViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var bottomMenuView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var addressTableView: UITableView!
    @IBOutlet weak var cancelImage: UIImageView!
    
    // MARK: - Variables
    
    var addressList = [Address]()
    let d = UserDefaults.standard
    let headers: HTTPHeaders = [
        "Content-Type": "application/json"
    ]
    
    // MARK: - View Funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressTableView.delegate = self
        addressTableView.dataSource = self
        
        let id = d.string(forKey: "id")
        takeAddresses(for: id!)

        bottomMenuView.layer.cornerRadius = 25
        bottomMenuView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomMenuView.clipsToBounds = true

        bottomMenuView.layer.shadowColor = UIColor.black.cgColor
        bottomMenuView.layer.shadowOffset = CGSize(width: 0, height: 3)
        bottomMenuView.layer.shadowOpacity = 0.8
        bottomMenuView.layer.shadowRadius = 4.0
        bottomMenuView.layer.masksToBounds = false
        
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        
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
                    self.addressList = data
                } else {
                    print("Hatalı API yanıtı")
                    self.addressList = [Address]()
                }
                DispatchQueue.main.async {
                    self.addressTableView.reloadData()
                }
            case .failure(let error):
                print("Hata oluştu: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteAddress(for id:Int){
        AF.request("https://ozerhamza.xyz/api/Adress/\(id)", method: .delete, headers: headers).response { response in
            debugPrint(response)
            let id = self.d.string(forKey: "id")
            self.takeAddresses(for: id!)
            DispatchQueue.main.async {
                self.addressTableView.reloadData()
            }
        }
    }
    
    // MARK: - objc Funcs
    
    @objc func cancelImageViewTapped(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "homePageVC") as? HomePageViewController {
            
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
            
            present(modalVC, animated: true, completion: nil)
        }

    }
    
    // MARK: - Actions
    
    @IBAction func buttonAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "adresMapVC") as? AdresMapViewController {
            
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
            
            self.present(modalVC, animated: true, completion: nil)
        }
    }
    
}

extension AddressViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let address = addressList[indexPath.row]
        let cell = addressTableView.dequeueReusableCell(withIdentifier: "adresTableViewCell", for: indexPath) as! adresTableViewCell
        if address.name == "Ev"{
            cell.addressImage.image = UIImage(systemName: "house")
        }else if address.name == "İş"{
            cell.addressImage.image = UIImage(systemName: "handbag")
        }else if address.name == "Eş"{
            cell.addressImage.image = UIImage(systemName: "heart")
        }else{
            cell.addressImage.image = UIImage(named: "adresIcon")
        }
        cell.nameLabel.text = address.name
        cell.addressLabel.text = "\(address.neighbourhood) Mah. \(address.street) No: \(address.buildingNo), \(address.districte) \(address.province)"
        cell.addressDescriptionLabel.text = "Adres Tarifi: \(address.adressDetails)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil") { (action, view, completion) in

            print("Silindi: \(self.addressList[indexPath.row].id)")
            self.deleteAddress(for: self.addressList[indexPath.row].id)

            completion(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "adresUpdateVC") as? AdresUpdateViewController {
            
            modalVC.address = self.addressList[indexPath.row]
            
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
            
            self.present(modalVC, animated: true, completion: nil)
        }
    }
}

// MARK: - Classes

class adresTableViewCell:UITableViewCell{
    
    @IBOutlet weak var addressImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressDescriptionLabel: UILabel!
    
}
