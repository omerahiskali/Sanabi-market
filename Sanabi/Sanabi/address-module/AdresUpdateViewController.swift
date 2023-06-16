//
//  AdresUpdateViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 31.05.2023.
//

import UIKit
import Alamofire

class AdresUpdateViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var firstAddressLine: UILabel!
    @IBOutlet weak var secondAddressLine: UILabel!
    @IBOutlet weak var ilceTextField: UITextField!
    @IBOutlet weak var semtTextField: UITextField!
    @IBOutlet weak var sokakTextField: UITextField!
    @IBOutlet weak var apartmanNoTextField: UITextField!
    @IBOutlet weak var postaKoduTextField: UITextField!
    @IBOutlet weak var daireNoTextField: UITextField!
    @IBOutlet weak var katTextField: UITextField!
    @IBOutlet weak var telefonNoTextField: UITextField!
    @IBOutlet weak var kuryeNotTextField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var cancelImage: UIImageView!
    
    // MARK: - Variables
    
    var address:Address?
    var textFields:[UITextField] = []
    let headers: HTTPHeaders = [
        "Content-Type": "application/json"
    ]
    let d = UserDefaults.standard
    
    // MARK: - View Funcs

    override func viewDidLoad() {
        super.viewDidLoad()

        textFields = [ilceTextField, semtTextField, sokakTextField, apartmanNoTextField, postaKoduTextField, daireNoTextField, katTextField, telefonNoTextField, kuryeNotTextField]
    
        for tf in textFields{
            tf.delegate = self
            tf.layer.cornerRadius = 7
            tf.clipsToBounds = true
            tf.layer.borderWidth = 0.4
            tf.layer.borderColor = UIColor.darkGray.cgColor
        }
        
        textFieldYaz()
        
        button.layer.cornerRadius = 10
        
        firstAddressLine.text = "\(address!.neighbourhood) Mah. \(address!.street) No: \(address!.buildingNo)"
        secondAddressLine.text = "\(address!.districte) \(address!.province) \(address!.postCode)"
        
        let cancelImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelImageViewTapped))
        cancelImage.addGestureRecognizer(cancelImageTapGesture)
        cancelImage.isUserInteractionEnabled = true
    }
    
    // MARK: - Funcs
    
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
    
    func textFieldYaz(){
        ilceTextField.text = address?.districte ?? ""
        semtTextField.text = address?.neighbourhood ?? ""
        sokakTextField.text = address?.street ?? ""
        apartmanNoTextField.text = String(address!.buildingNo)
        postaKoduTextField.text = String(address!.postCode)
        daireNoTextField.text = String(address!.apartmentNumber)
        telefonNoTextField.text = address?.numberPhone ?? ""
        kuryeNotTextField.text = address?.adressDetails ?? ""
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
    
    func updateAddress(id: Int, name: String, province: String, districte: String, neighbourhood: String, street: String, buildingNo: Int, postCode: Int, apartmentNumber: Int, addressDetails: String, numberPhone: String, customerId:Int, createDate:String) {
        let url = "https://ozerhamza.xyz/api/Adress"
        
        let params: Parameters = [
            "id": id,
            "name": name,
            "province": province,
            "districte": districte,
            "neighbourhood": neighbourhood,
            "street": street,
            "buildingNo": buildingNo,
            "postCode": postCode,
            "apartmentNumber": apartmentNumber,
            "adressDetails": addressDetails,
            "numberPhone": numberPhone,
            "customerId": customerId,
            "createDate": createDate
        ]
        
        AF.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).response { response in
            if let error = response.error {
                print("Hata oluştu: \(error.localizedDescription)")
                return
            }
            
            if let data = response.data {
                do {
                    let cevap = try JSONSerialization.jsonObject(with: data)
                    print(cevap)

                } catch {
                    print("Hata oluştu: \(error.localizedDescription)")
                    self.button.isEnabled = true
                }
            }
        }
    }
    
    // MARK: - objc Funcs
    
    @objc func cancelImageViewTapped(){
        dismiss(animated: true)
    }

    
    // MARK: - Actions
    
    @IBAction func buttonAction(_ sender: Any) {
        var textFieldControl = false
        textFields = [ilceTextField, semtTextField, sokakTextField, apartmanNoTextField, postaKoduTextField, daireNoTextField, katTextField, telefonNoTextField, kuryeNotTextField]
        for tf in textFields{
            if tf.text == ""{
                textFieldError(textField: tf)
                textFieldControl = false
                break
            }else{
                textFieldControl = true
            }
        }
        if textFieldControl{
            print("başarılı")
            button.isEnabled = false
            let id = d.string(forKey: "id")
            updateAddress(id: address!.id, name: address!.name, province: address!.province, districte: ilceTextField.text!, neighbourhood: semtTextField.text!, street: sokakTextField.text!, buildingNo: Int(apartmanNoTextField.text!)!, postCode: Int(postaKoduTextField.text!)!, apartmentNumber: Int(daireNoTextField.text!)!, addressDetails: kuryeNotTextField.text!, numberPhone: telefonNoTextField.text!, customerId: Int(id!)!, createDate: address!.createDate!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let modalVC = storyboard.instantiateViewController(withIdentifier: "addressVC") as? AddressViewController {
                    
                    modalVC.modalTransitionStyle = .coverVertical
                    modalVC.modalPresentationStyle = .fullScreen
                    
                    self.present(modalVC, animated: true, completion: nil)
                }
            }
        }
    }
    

}
