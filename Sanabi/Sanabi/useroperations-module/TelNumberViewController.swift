//
//  TelNumberViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 9.06.2023.
//

import UIKit
import Alamofire

class TelNumberViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var telNumberTextField: UITextField!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var backImage: UIImageView!
    
    // MARK: - Variables
    
    var customer:Customer?
    let headers: HTTPHeaders = [
        "Content-Type": "application/json"
    ]
    
    // MARK: - View Funcs

    override func viewDidLoad() {
        super.viewDidLoad()

        telNumberTextField.delegate = self
        
        telNumberTextField.layer.cornerRadius = 10
        telNumberTextField.clipsToBounds = true
        telNumberTextField.layer.borderWidth = 0.7
        telNumberTextField.layer.borderColor = UIColor.darkGray.cgColor
        telNumberTextField.clearButtonMode = .never
        
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        
        buttonContainerView.layer.cornerRadius = 25
        buttonContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        buttonContainerView.clipsToBounds = true

        buttonContainerView.layer.shadowColor = UIColor.black.cgColor
        buttonContainerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        buttonContainerView.layer.shadowOpacity = 0.8
        buttonContainerView.layer.shadowRadius = 4.0
        buttonContainerView.layer.masksToBounds = false
        
        if let customer = customer{
            telNumberTextField.text = customer.numberPhone
        }
        
        let backImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(backImageViewTapped))
        backImage.addGestureRecognizer(backImageTapGesture)
        backImage.isUserInteractionEnabled = true
        
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
        textField.layer.borderWidth = 0.7
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
    
    func updateCustomer(id: Int, name: String, surname: String, mail: String, numberPhone: String, birtDate: String, createDate: String) {
        let url = "https://ozerhamza.xyz/api/Customers"
        
        let params: Parameters = [
            "id": id,
            "name": name,
            "surname": surname,
            "mail": mail,
            "numberPhone": numberPhone,
            "birtDate": birtDate,
            "createDate": createDate
        ]
        
        AF.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: Empty.self) { response in
                switch response.result {
                case .success:
                    // Başarılı
                    print("Update successful")
                    self.goBack()
                    
                case .failure(let error):
                    // Hata
                    print("Hata oluştu: \(error.localizedDescription)")
                    self.button.isEnabled = true
                }
            }
    }
    
    func goBack() {
        
        customer!.numberPhone = telNumberTextField.text!
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "userOperationsVC") as? UserOperationsViewController {
            
            modalVC.customer = self.customer
            
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
            
            self.present(modalVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - objc Funcs
    
    @objc func backImageViewTapped(){
        dismiss(animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func buttonActions(_ sender: Any) {
        button.isEnabled = false
        if let telNumber = telNumberTextField.text, let customer = customer{
            if telNumber.count == 10{
                updateCustomer(id: customer.id, name: customer.name, surname: customer.surname, mail: customer.mail!, numberPhone: telNumber, birtDate: customer.birtDate!, createDate: customer.createDate!)
            }else{
                textFieldError(textField: telNumberTextField)
                button.isEnabled = true
            }
        }else{
            textFieldError(textField: telNumberTextField)
            button.isEnabled = true
        }
    }
    

}
