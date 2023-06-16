//
//  AdresKayitViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 29.05.2023.
//

import UIKit
import MapKit
import Alamofire

class AdresKayitViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var cancelImage: UIImageView!
    @IBOutlet weak var firstAddressLine: UILabel!
    @IBOutlet weak var secondAddressLine: UILabel!
    @IBOutlet weak var ilceTextField: UITextField!
    @IBOutlet weak var semtTextField: UITextField!
    @IBOutlet weak var sokakTextField: UITextField!
    @IBOutlet weak var apartmanNoTextField: UITextField!
    @IBOutlet weak var postaKodTextField: UITextField!
    @IBOutlet weak var daireNoTextField: UITextField!
    @IBOutlet weak var katTextField: UITextField!
    @IBOutlet weak var telefonNoTextField: UITextField!
    @IBOutlet weak var kuryeNotTextField: UITextField!
    @IBOutlet weak var evImage: UIImageView!
    @IBOutlet weak var isImage: UIImageView!
    @IBOutlet weak var esImage: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    // MARK: - Variables
    
    var placemark:CLPlacemark?
    var pinLocation:CLLocation?
    var textFields:[UITextField] = []
    var selectedImage = "Ev"
    let headers: HTTPHeaders = [
        "Content-Type": "application/json"
    ]
    let d = UserDefaults.standard
    
    // MARK: - View Funcs

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFields = [ilceTextField, semtTextField, sokakTextField, apartmanNoTextField, postaKodTextField, daireNoTextField, katTextField, telefonNoTextField, kuryeNotTextField]
    
        for tf in textFields{
            tf.delegate = self
            tf.layer.cornerRadius = 7
            tf.clipsToBounds = true
            tf.layer.borderWidth = 0.4
            tf.layer.borderColor = UIColor.darkGray.cgColor
        }
        
        textFieldYaz()
        
        firstAddressLine.text = "\(placemark!.subLocality ?? "") Mah. \(placemark!.thoroughfare ?? "") No: \(placemark!.subThoroughfare ?? "")"
        secondAddressLine.text = "\(placemark!.locality ?? "") \(placemark!.administrativeArea ?? "") \(placemark!.postalCode ?? "")"
        
        button.layer.cornerRadius = 10

        menuView.layer.cornerRadius = 25
        menuView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        menuView.clipsToBounds = true

        menuView.layer.shadowColor = UIColor.black.cgColor
        menuView.layer.shadowOffset = CGSize(width: 0, height: 3)
        menuView.layer.shadowOpacity = 0.8
        menuView.layer.shadowRadius = 4.0
        menuView.layer.masksToBounds = false
        
        setImageView()
        
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        let pinAnnotation = MKPointAnnotation()
        pinAnnotation.coordinate = pinLocation!.coordinate
        mapView.addAnnotation(pinAnnotation)
        
        let region = MKCoordinateRegion(center: pinLocation!.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
        mapView.setRegion(region, animated: true)
        
        let evImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(evImageViewTapped))
        evImage.addGestureRecognizer(evImageTapGesture)
        evImage.isUserInteractionEnabled = true
        
        let isImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(isImageViewTapped))
        isImage.addGestureRecognizer(isImageTapGesture)
        isImage.isUserInteractionEnabled = true
        
        let esImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(esImageViewTapped))
        esImage.addGestureRecognizer(esImageTapGesture)
        esImage.isUserInteractionEnabled = true
        
        let cancelImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelImageViewTapped))
        cancelImage.addGestureRecognizer(cancelImageTapGesture)
        cancelImage.isUserInteractionEnabled = true

    }
    
    //MARK: - Funcs
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor.black.cgColor
        textField.clearButtonMode = .always
        if let clearButton = textField.value(forKey: "_clearButton") as? UIButton {
            let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
            clearButton.setImage(templateImage, for: .normal)
            clearButton.tintColor = .black
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0.4
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.clearButtonMode = .never
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldError(textField:UITextField){
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor.red.cgColor
        textField.clearButtonMode = .always
        if let clearButton = textField.value(forKey: "_clearButton") as? UIButton {
            let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
            clearButton.setImage(templateImage, for: .normal)
            clearButton.tintColor = .red
        }
    }
    
    func textFieldYaz(){
        if let locality = placemark?.locality{
            self.ilceTextField.text = locality
        }
        if let subLocality = placemark?.subLocality{
            self.semtTextField.text = subLocality
        }
        if let thoroughfare = placemark?.thoroughfare{
            self.sokakTextField.text = thoroughfare
        }
        if let subThoroughfare = placemark?.subThoroughfare{
            self.apartmanNoTextField.text = subThoroughfare
        }
        if let postalCode = placemark?.postalCode{
            self.postaKodTextField.text = postalCode
        }
    }
    
    func setImageView(){
        let imageViews:[UIImageView] = [cancelImage, evImage, isImage, esImage]
        for i in imageViews{
            i.layer.cornerRadius = i.bounds.height / 2
            i.clipsToBounds = true
            i.layer.shadowColor = UIColor.black.cgColor
            i.layer.shadowOpacity = 0.4
            i.layer.shadowOffset = CGSize(width: 0, height: 0)
            i.layer.shadowRadius = 4
            i.layer.masksToBounds = false
        }
    }
    
    func addAddress(name:String,province:String,districte:String,neighbourhood:String,street:String,buildingNo:Int,postCode:Int,apartmentNumber:Int,adressDetails:String,numberPhone:String,customerId:Int,createDate:String){
        let params:Parameters = ["name":name,
                                 "province":province,
                                 "districte":districte,
                                 "neighbourhood":neighbourhood,
                                 "street":street,
                                 "buildingNo":buildingNo,
                                 "postCode":postCode,
                                 "apartmentNumber":apartmentNumber,
                                 "adressDetails":adressDetails,
                                 "numberPhone":numberPhone,
                                 "customerId":customerId,
                                 "createDate":createDate] // Web Service e gidecek veriler
        
        AF.request("https://ozerhamza.xyz/api/Adress", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).response { response in
            
            if let data = response.data{
                do{
                    // API Kayıt başarılı
                    let cevap = try JSONSerialization.jsonObject(with: data)
                    print(cevap)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let modalVC = storyboard.instantiateViewController(withIdentifier: "addressVC") as? AddressViewController {
                        
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
    
    @objc func evImageViewTapped() {
        print("ev basıldı")
        if selectedImage != "Ev"{
            evImage.backgroundColor = UIColor(named: "maincolor")
            evImage.tintColor = UIColor(named: "thirdcolor")
            if selectedImage == "İş"{
                isImage.backgroundColor = UIColor(named: "thirdcolor")
                isImage.tintColor = UIColor(named: "maincolor")
            }else if selectedImage == "Eş"{
                esImage.backgroundColor = UIColor(named: "thirdcolor")
                esImage.tintColor = UIColor(named: "maincolor")
            }
            selectedImage = "Ev"
        }
    }
    
    @objc func isImageViewTapped() {
        print("iş basıldı")
        if selectedImage != "İş"{
            isImage.backgroundColor = UIColor(named: "maincolor")
            isImage.tintColor = UIColor(named: "thirdcolor")
            if selectedImage == "Ev"{
                evImage.backgroundColor = UIColor(named: "thirdcolor")
                evImage.tintColor = UIColor(named: "maincolor")
            }else if selectedImage == "Eş"{
                esImage.backgroundColor = UIColor(named: "thirdcolor")
                esImage.tintColor = UIColor(named: "maincolor")
            }
            selectedImage = "İş"
        }
    }
    
    @objc func esImageViewTapped() {
        print("eş basıldı")
        if selectedImage != "Eş"{
            esImage.backgroundColor = UIColor(named: "maincolor")
            esImage.tintColor = UIColor(named: "thirdcolor")
            if selectedImage == "İş"{
                isImage.backgroundColor = UIColor(named: "thirdcolor")
                isImage.tintColor = UIColor(named: "maincolor")
            }else if selectedImage == "Ev"{
                evImage.backgroundColor = UIColor(named: "thirdcolor")
                evImage.tintColor = UIColor(named: "maincolor")
            }
            selectedImage = "Eş"
        }
    }
    
    @objc func cancelImageViewTapped(){
        dismiss(animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func buttonAction(_ sender: Any) {
        var textFieldControl = false
        textFields = [ilceTextField, semtTextField, sokakTextField, apartmanNoTextField, postaKodTextField, daireNoTextField, katTextField, telefonNoTextField, kuryeNotTextField]
        for tf in textFields{
            if tf.text == ""{
                textFieldError(textField: tf)
                textFieldControl = false
            }else{
                textFieldControl = true
            }
        }
        if textFieldControl{
            print("başarılı")
            button.isEnabled = false
            let id = d.string(forKey: "id")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            let currentDate = Date()
            let formattedDate = dateFormatter.string(from: currentDate)
            addAddress(name: selectedImage, province: placemark!.administrativeArea!, districte: ilceTextField.text!, neighbourhood: semtTextField.text!, street: sokakTextField.text!, buildingNo: Int(apartmanNoTextField.text!)!, postCode: Int(postaKodTextField.text!)!, apartmentNumber: Int(daireNoTextField.text!)!, adressDetails: kuryeNotTextField.text!, numberPhone: telefonNoTextField.text!, customerId: Int(id!)!, createDate: formattedDate)
        }
    }
    

}
