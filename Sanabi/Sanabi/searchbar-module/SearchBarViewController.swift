//
//  SearchBarViewController.swift
//  Sanabi
//
//  Created by Ömer Faruk Küçükahıskalı on 12.06.2023.
//

import UIKit
import Alamofire

class SearchBarViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cancelImage: UIImageView!
    @IBOutlet weak var searchBarTableView: UITableView!
    
    // MARK: - Variables
    
    var productList = [Products]()
    var filteredList = [Products]()
    
    // MARK: - View Funcs

    override func viewDidLoad() {
        super.viewDidLoad()
        
        takeProducts()
        
        searchBar.delegate = self
        
        searchBarTableView.delegate = self
        searchBarTableView.dataSource = self
        
        let cancelImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelImageViewTapped))
        cancelImage.addGestureRecognizer(cancelImageTapGesture)
        cancelImage.isUserInteractionEnabled = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchBar.becomeFirstResponder()
        
    }
    
    // MARK: - Funcs
    
    func takeProducts() {
        let url = "https://ozerhamza.xyz/api/Products"
        
        AF.request(url).responseDecodable(of: ProductList.self) { response in
            switch response.result {
            case .success(let value):
                if let data = value.data{
                    self.productList = data
                    print("productList count : \(self.productList.count)")
                } else {
                    print("Hatalı API yanıtı")
                    self.productList = [Products]()
                }
                DispatchQueue.main.async {
                    self.searchBarTableView.reloadData()
                }
            case .failure(let error):
                print("Hata oluştu: \(error.localizedDescription)")
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterProducts(for: searchText)
        searchBarTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        filteredList.removeAll()
        searchBarTableView.reloadData()
    }
    
    func filterProducts(for searchText: String) {
        if searchText.isEmpty {
            filteredList = []
        } else {
            filteredList = productList.filter { $0.name.lowercased().hasPrefix(searchText.lowercased()) }
        }
    }
    
    // MARK: - objc Funcs
    
    @objc func cancelImageViewTapped(){
        dismiss(animated: true)
    }
    
}

// MARK: - Extensions

extension SearchBarViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchBarCell", for: indexPath) as! SearchBarTableViewCell
        let product = filteredList[indexPath.row]
        cell.productLabel.text = product.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = filteredList[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let urunlerVC = storyboard.instantiateViewController(withIdentifier: "urunBilgiVC") as? UrunBilgiViewController {
            
            urunlerVC.product = product
            urunlerVC.viewControllerId = "searchBarVC"
            
            urunlerVC.modalTransitionStyle = .coverVertical
            urunlerVC.modalPresentationStyle = .fullScreen
            
            present(urunlerVC, animated: true, completion: nil)
        }
    }
    
}

// MARK: - Classes

class SearchBarTableViewCell: UITableViewCell{
    
    @IBOutlet weak var productLabel: UILabel!
    
}
