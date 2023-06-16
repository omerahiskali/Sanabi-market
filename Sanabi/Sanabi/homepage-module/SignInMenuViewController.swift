//
//  SignInMenuViewController
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 22.05.2023.
//

import UIKit

class SignInMenuViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var signInWithAppleButton: UIButton!
    @IBOutlet weak var signInWithFacebookButton: UIButton!
    @IBOutlet weak var signInWithGoogleButton: UIButton!
    @IBOutlet weak var signInWithEmailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signInWithAppleButton.layer.cornerRadius = 13
        signInWithAppleButton.clipsToBounds = true
        signInWithAppleButton.layer.borderWidth = 0.5
        signInWithAppleButton.layer.borderColor = UIColor.gray.cgColor
        
        signInWithFacebookButton.layer.cornerRadius = 13
        signInWithFacebookButton.clipsToBounds = true
        signInWithFacebookButton.layer.borderWidth = 0.5
        signInWithFacebookButton.layer.borderColor = UIColor.gray.cgColor
        
        signInWithGoogleButton.layer.cornerRadius = 13
        signInWithGoogleButton.clipsToBounds = true
        signInWithGoogleButton.layer.borderWidth = 0.5
        signInWithGoogleButton.layer.borderColor = UIColor.gray.cgColor
        
        signInWithEmailButton.layer.cornerRadius = 13
        signInWithEmailButton.clipsToBounds = true
        if let mainColor = UIColor(named: "maincolor"){
            signInWithEmailButton.layer.borderWidth = 0.5
            signInWithEmailButton.layer.borderColor = mainColor.cgColor
        }
        
    }

    @IBAction func emailButtonAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let modalVC = storyboard.instantiateViewController(withIdentifier: "logInVC") as? LogInViewController {
            
            modalVC.modalTransitionStyle = .coverVertical
            modalVC.modalPresentationStyle = .fullScreen
            
            self.present(modalVC, animated: true, completion: nil)
        }

    }
    

    
}
