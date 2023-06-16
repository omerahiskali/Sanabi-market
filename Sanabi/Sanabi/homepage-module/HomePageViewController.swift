//
//  HomePageViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 23.03.2023.
//

import UIKit
import CoreLocation
import Alamofire

class HomePageViewController: UIViewController, UISearchBarDelegate{
 
    // MARK: - Outlets
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var swipeGesture: UISwipeGestureRecognizer!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var menuIcon: UIImageView!
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var firstAddressLine: UILabel!
    @IBOutlet weak var secondAddressLine: UILabel!
    @IBOutlet weak var anaMenuSearchBar: UISearchBar!
    @IBOutlet weak var mahalleImageView: UIImageView!
    @IBOutlet weak var yemekImageView: UIImageView!
    @IBOutlet weak var marketImageView: UIImageView!
    @IBOutlet weak var gelalImageView: UIImageView!
    @IBOutlet weak var cartImage: UIImageView!
    
    // MARK: - Variables
    
    var menuController: SignInViewController?
    var menu = false
    let screen = UIScreen.main.bounds
    var home = CGAffineTransform()
    let d = UserDefaults.standard
    var menuView: UIView?
    let locationManager = CLLocationManager()
    struct option{
        var title = String()
        var segue = String()
        var image = String()
    }
    var options:[option] = []
    var name:String?
    var customer:Customer?
    
    // MARK: - View Load

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let id = d.string(forKey: "id") ?? "empty"
        
        if id == "empty"{
            idControlEmpty()
        }else{
            fetchData(for: id)
        }
        
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.backgroundColor = .clear
        
        home = containerView.transform

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            menuIcon.isUserInteractionEnabled = true
            menuIcon.addGestureRecognizer(tapGestureRecognizer)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        anaMenuSearchBar.delegate = self
        
        anaMenuSearchBar.barTintColor = UIColor(named: "maincoloralt")
        if let searchField = anaMenuSearchBar.value(forKey: "searchField") as? UITextField {
            searchField.backgroundColor = UIColor.white
        }
        
        setImages(image: mahalleImageView)
        setImages(image: marketImageView)
        setImages(image: gelalImageView)
        setImages(image: yemekImageView)
        
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        marketImageView.addGestureRecognizer(imageTapGesture)
        marketImageView.isUserInteractionEnabled = true
        
        let cartImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(cartImageViewTapped))
        cartImage.addGestureRecognizer(cartImageTapGesture)
        cartImage.isUserInteractionEnabled = true

    }
    
    // MARK: - Funcs
    
    func fetchData(for id: String) {
        let url = "https://ozerhamza.xyz/api/Customers/\(id)"
        
        AF.request(url).responseDecodable(of: CustomerData.self) { response in
            switch response.result {
            case .success(let value):
                if let data = value.data{
                    self.customer = data
                    print("id: \(data.id)")
                    let name = "\(data.name) \(data.surname)"
                    self.idControlFull(name: name)
                    self.menuTableView.reloadData()
                } else {
                    print("Hatalı API yanıtı")
                }
            case .failure(let error):
                print("Hata oluştu: \(error.localizedDescription)")
            }
        }
    }
    
    func idControlEmpty(){
        options = [
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "Ayarlar",segue: "ayarSegue", image: "ayarIcon"),
            option(title: "Daha Fazla",segue: "dahaFazlaSegue", image: "dahaFazlaIcon"),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "Kaydol veya giriş yap",segue: "girisMenuSegue", image: "cikisIcon")
        ]
        cartImage.isHidden = true
    }
    
    func idControlFull(name:String){
        options = [
            option(title: name,segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "Önceki Siparişlerim",segue: "siparisSegue", image: "siparisIcon"),
            option(title: "Hesabım",segue: "hesapSegue", image: "hesapIcon"),
            option(title: "Adreslerim",segue: "adresSegue", image: "adresIcon"),
            option(title: "Ayarlar",segue: "ayarSegue", image: "ayarIcon"),
            option(title: "Daha Fazla",segue: "dahaFazlaSegue", image: "dahaFazlaIcon"),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "",segue: "", image: ""),
            option(title: "Çıkış Yap",segue: "cikisSegue", image: "cikisIcon")
        ]
        cartImage.isHidden = false
        self.menuTableView.reloadData()
    }
    
    func showMenu(){
        self.containerView.layer.cornerRadius = 40.0
        self.topContainer.layer.cornerRadius = self.containerView.layer.cornerRadius
        self.topContainer.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        
        let x = screen.width * 0.8
        let originalTransform = self.containerView.transform
        let scaledTransform = originalTransform.scaledBy(x: 0.8, y: 0.8)
        let scaledAndTranslatedTransform = scaledTransform.translatedBy(x: x, y: 0)
        
        UIView.animate(withDuration: 0.7, animations: {
            self.containerView.transform = scaledAndTranslatedTransform
        })
    }
    
    func hideMenu(){
        UIView.animate(withDuration: 0.7, animations: {
            self.containerView.transform = self.home
        })
    }
    
    func showGirisMenu(){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "signInMenuVC")
            if let presentationController = viewController.presentationController as? UISheetPresentationController{
                presentationController.detents = [.medium()]
                presentationController.preferredCornerRadius = 20
                presentationController.prefersGrabberVisible = true
                presentationController.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            self.present(viewController, animated: true)
    }
    
    func setImages(image:UIImageView){
        image.layer.cornerRadius = 10
        image.layer.masksToBounds = true
        image.layer.shadowColor = UIColor.black.cgColor
        image.layer.shadowOpacity = 0.7
        image.layer.shadowOffset = CGSize(width: 0, height: 2)
        image.layer.shadowRadius = 4
    }
    
    func exitAuth(){
        let alertController = UIAlertController(title: "Çıkış mı yapıyorsunuz?", message: "Uğradığınız için teşekkürler. Yakında tekrar görüşmek üzere!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Çıkış yap", style: .default) { _ in
            self.d.removeObject(forKey: "id")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let modalVC = storyboard.instantiateViewController(withIdentifier: "mainVC") as? ViewController {
                modalVC.modalTransitionStyle = .coverVertical
                modalVC.modalPresentationStyle = .fullScreen
                
                self.present(modalVC, animated: true, completion: nil)
            }
        })
        alertController.addAction(UIAlertAction(title: "Vazgeç", style: .cancel) { _ in
            
        })
        present(alertController, animated: true, completion: nil)
    }
    
    func getAddressFromLocation(_ location: CLLocation, completion: @escaping (CLPlacemark) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Adres alınamadı: \(error.localizedDescription)")

                return
            }
            
            if let placemark = placemarks?.first {
                completion(placemark)
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
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if menu == false{
            showMenu()
            menu = true
        }else{
            hideMenu()
            menu = false
        }

    }
    
    @objc func imageViewTapped() {
        let id = d.string(forKey: "id") ?? "empty"
        if id == "empty"{
                let alertController = UIAlertController(title: "Giriş yapmadınız", message: "Lütfen sipariş vermek için önce giriş yapınız", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Tamam", style: .default) { _ in
                    alertController.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let modalVC = storyboard.instantiateViewController(withIdentifier: "marketKategoriVC") as? MarketKategoriViewController {
                
                modalVC.modalTransitionStyle = .coverVertical
                modalVC.modalPresentationStyle = .fullScreen
                
                self.present(modalVC, animated: true, completion: nil)
            }
        }
    }
    
    @objc func cartImageViewTapped(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let urunlerVC = storyboard.instantiateViewController(withIdentifier: "sepetVC") as? SepetViewController {
            
            urunlerVC.modalTransitionStyle = .coverVertical
            urunlerVC.modalPresentationStyle = .fullScreen
            
            present(urunlerVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Actions

    
    @IBAction func showMenu(_ sender: Any) {
        if menu == false && swipeGesture.direction == .right{
            showMenu()
            menu = true
        }
    }
    
    @IBAction func hideMenu(_ sender: Any) {
        if menu == true{
            hideMenu()
            menu = false
        }
    }
    
}

// MARK: - Extensions

extension HomePageViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if options[indexPath.row].segue == ""{
            let cell = menuTableView.dequeueReusableCell(withIdentifier: "tableViewCell1", for: indexPath) as! tableViewCell1
            cell.backgroundColor = .clear
            cell.label.text = options[indexPath.row].title
            return cell
        }else{
            let cell = menuTableView.dequeueReusableCell(withIdentifier: "tableViewCell2", for: indexPath) as! tableViewCell2
            cell.backgroundColor = .clear
            cell.label.text = options[indexPath.row].title
            cell.menuImage.image = UIImage(named: options[indexPath.row].image)
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow{
            
            if options[indexPath.row].segue != ""{
                
                let currentCell = (tableView.cellForRow(at: indexPath) ?? UITableViewCell()) as UITableViewCell
                
                currentCell.alpha = 0.5
                UIView.animate(withDuration: 1, animations: {
                    currentCell.alpha = 1
                })
                
                print(options[indexPath.row].segue)
                
                if options[indexPath.row].segue == "girisMenuSegue"{
                    hideMenu()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.showGirisMenu()
                    }
                }else if options[indexPath.row].segue == "cikisSegue"{
                    hideMenu()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.exitAuth()
                    }
                }else if options[indexPath.row].segue == "adresSegue"{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let modalVC = storyboard.instantiateViewController(withIdentifier: "addressVC") as? AddressViewController {
                        
                        modalVC.modalTransitionStyle = .coverVertical
                        modalVC.modalPresentationStyle = .fullScreen
                        
                        self.present(modalVC, animated: true, completion: nil)
                    }
                }else if options[indexPath.row].segue == "hesapSegue"{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let modalVC = storyboard.instantiateViewController(withIdentifier: "userOperationsVC") as? UserOperationsViewController {
                        
                        modalVC.customer = self.customer
                        
                        modalVC.modalTransitionStyle = .coverVertical
                        modalVC.modalPresentationStyle = .fullScreen
                        
                        self.present(modalVC, animated: true, completion: nil)
                    }
                }else if options[indexPath.row].segue == "siparisSegue"{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let modalVC = storyboard.instantiateViewController(withIdentifier: "oncekiSiparisVC") as? OncekiSiparisViewController {
                                                
                        modalVC.modalTransitionStyle = .coverVertical
                        modalVC.modalPresentationStyle = .fullScreen
                        
                        self.present(modalVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension HomePageViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else {
            return
        }
        
        getAddressFromLocation(userLocation) { (address) in
            self.firstAddressLine.text = "\(address.subLocality ?? "") Mah. \(address.thoroughfare ?? "") No: \(address.subThoroughfare ?? "")"
            self.secondAddressLine.text = "\(address.locality ?? "") \(address.administrativeArea ?? "") \(address.postalCode ?? "")"
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum hizmetleri alınamadı: \(error.localizedDescription)")
    }
}

// MARK: - Classes

class tableViewCell1: UITableViewCell{
    
    @IBOutlet weak var label: UILabel!
    
}


class tableViewCell2: UITableViewCell{
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var menuImage: UIImageView!
    
}




