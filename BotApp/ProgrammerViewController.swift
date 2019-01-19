//
//  ProgrammerViewController.swift
//  BotApp
//
//  Created by lu on 19/01/2019.
//  Copyright © 2019 lu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import IHKeyboardAvoiding

class ProgrammerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
    var typeOfAnswers = [1, 0, 1]
    var answersArray = ["ciao!", "heila!", "di cosa hai bisogno)"]
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        textField.autocorrectionType = .no
        
        self.hideKeyboardWhenTappedAround()
        self.textField.delegate = self
        KeyboardAvoiding.avoidingView = self.view
        
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return answersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch typeOfAnswers[indexPath.row] {
            
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "programmerCell", for: indexPath) as! ProgrammerCollectionViewCell
            
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MessageCollectionViewCell
            
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MessageCollectionViewCell
            
            return cell
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        
        let content : String = textField.text!
        textField.text = ""
        
        let parameters : Parameters = [
            "content": content
        ]
        print(parameters)
        //sendQuestion(url: "query", pam: parameters)
        return true
    }
}
