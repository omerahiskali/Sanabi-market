//
//  SignInTelViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 26.05.2023.
//

import UIKit
import Alamofire
import FirebaseAuth

class SignInTelViewController: UIViewController, UITextFieldDelegate  {
    
    //MARK: - Outlets
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneNumberErrorMessageLabel: UILabel!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var buttonLabel: UILabel!
    
    //MARK: - Variables
    
    var email:String?
    var name:String?
    var surname:String?
    var birthDate:String?
    var password:String?
    var buttonBottomConstraintConstant: CGFloat = 0.0
    let headers: HTTPHeaders = [
        "Content-Type": "application/json"
    ]
    struct APIResponse: Decodable {
        let data: Int?
    }
    let d = UserDefaults.standard
    
    //MARK: - View Funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()

        phoneNumberTextField.delegate = self
        
        phoneNumberTextField.layer.cornerRadius = 10
        phoneNumberTextField.clipsToBounds = true
        phoneNumberTextField.layer.borderWidth = 0.7
        phoneNumberTextField.layer.borderColor = UIColor.darkGray.cgColor
        
        phoneNumberErrorMessageLabel.alpha = 0
        
        button.layer.cornerRadius = 10
        buttonBottomConstraintConstant = buttonBottomConstraint.constant
        
        let backImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(backImageViewTapped))
        backImage.addGestureRecognizer(backImageTapGesture)
        backImage.isUserInteractionEnabled = true
        
        let buttonLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonLabelViewTapped))
        buttonLabel.addGestureRecognizer(buttonLabelTapGesture)
        buttonLabel.isUserInteractionEnabled = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Funcs
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        phoneNumberTextField.layer.borderWidth = 1.5
        phoneNumberTextField.layer.borderColor = UIColor.black.cgColor
        phoneNumberErrorMessageLabel.alpha = 0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        phoneNumberTextField.layer.borderWidth = 0.7
        phoneNumberTextField.layer.borderColor = UIColor.darkGray.cgColor
        phoneNumberErrorMessageLabel.alpha = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldError(){
        phoneNumberTextField.layer.borderWidth = 1.5
        phoneNumberTextField.layer.borderColor = UIColor.red.cgColor
        phoneNumberErrorMessageLabel.alpha = 1
    }
    
    func phoneNumberTextFieldControl() -> Bool {
        guard let text = phoneNumberTextField.text else {
            return false
        }
        
        let characterCount = text.count
        return characterCount == 10
    }

    func buttonActionFunc(){
        if phoneNumberTextFieldControl(){
            if let email = self.email, let password = self.password{
                self.button.isEnabled = false
                createCustomerFirebase(email: email, password: password)
            }
        }else{
            textFieldError()
        }
    }
    
    func createCustomerApi(name:String,surname:String,mail:String,numberPhone:String,birthDate:String, createDate:String){
        let params:Parameters = ["name":name,
                                 "surname":surname,
                                 "mail":mail,
                                 "numberPhone":numberPhone,
                                 "birtDate":birthDate,
                                 "createDate":createDate] // Web Service e gidecek veriler
        
        AF.request("https://ozerhamza.xyz/api/Customers", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).response { response in
            
            if let data = response.data{
                do{
                    let cevap = try JSONSerialization.jsonObject(with: data)
                    print(cevap)
                    self.setID()
                }catch{
                    print(error.localizedDescription)
                    self.button.isEnabled = true
                }
            }
        }
    }
    
    func createCustomerFirebase(email:String,password:String){
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
          if let error = error {
            print("Kayıt Hatası: \(error.localizedDescription)")
              self.button.isEnabled = true
          } else {
              if let name = self.name, let surname = self.surname, let birthDate = self.birthDate, let numberPhone = self.phoneNumberTextField.text{
                  let dateFormatter = DateFormatter()
                  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                  let currentDate = Date()
                  let formattedDate = dateFormatter.string(from: currentDate)
                  self.createCustomerApi(name: name, surname: surname, mail: email, numberPhone: numberPhone, birthDate: birthDate, createDate: formattedDate)
              }
          }
        }
    }
    
    func getCustomerId(withEmail email: String, completion: @escaping (Int?) -> Void) {
        let urlString = "https://ozerhamza.xyz/api/Customers/GetIdWithMail?mail=\(email)"
        
        AF.request(urlString).responseDecodable(of: APIResponse.self) { response in
            switch response.result {
            case .success(let apiResponse):
                completion(apiResponse.data)
            case .failure(let error):
                print("Request failed with error: \(error)")
                completion(nil)
            }
        }
    }
    
    func setID(){
        if let email = self.email{
            getCustomerId(withEmail: email) { customerId in
                if let customerId = customerId {
                    self.d.set(String(customerId), forKey: "id")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let modalVC = storyboard.instantiateViewController(withIdentifier: "homePageVC") as? HomePageViewController {
                        modalVC.modalTransitionStyle = .crossDissolve
                        modalVC.modalPresentationStyle = .fullScreen
                        self.present(modalVC, animated: true, completion: nil)
                    }
                } else {
                    self.setID()
                }
            }
        }
    }
    
    //MARK: - objc Funcs
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let buttonFrame = button.convert(button.bounds, to: view)
            let buttonBottomY = buttonFrame.origin.y + buttonFrame.size.height
            let keyboardTopY = view.frame.size.height - keyboardFrame.size.height - 10

            if buttonBottomY > keyboardTopY {
                let difference = buttonBottomY - keyboardTopY
                buttonBottomConstraint.constant = buttonBottomConstraintConstant + difference
                view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        buttonBottomConstraint.constant = buttonBottomConstraintConstant
        view.layoutIfNeeded()
    }
    
    @objc func backImageViewTapped(){
        dismiss(animated: true)
    }
    
    @objc func buttonLabelViewTapped(){
        buttonActionFunc()
    }
    
    //MARK: - Actions
    
    @IBAction func buttonAction(_ sender: Any) {
        buttonActionFunc()
    }
    
}



