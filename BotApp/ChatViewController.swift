//
//  ChatViewController.swift
//  BotApp
//
//  Created by lu on 19/01/2019.
//  Copyright © 2019 lu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Keyboardy

class ChatViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var textField: UITextField!
    
    var typeOfAnswers = [Int]()
    var answersArray = [String]()
    var myQuestion : Bool = false
    
    enum typeOfAnswer : String {
        case angry = "You seem angry"
        case what = "I didn't get it"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        textField.autocorrectionType = .no
        
        self.hideKeyboardWhenTappedAround()
        self.textField.delegate = self
    }
    
    public func sendQuestion(url: String, pam: Parameters) {
        
        print(pam)
        print(answersArray)
        
        Alamofire.request("http://localhost:8000/api/" + url, method: .post, parameters: pam).responseJSON { response in
            response.result.ifSuccess {
                self.myQuestion = false
                let json = JSON(response.result.value!)
                sleep(1)
                if (json["content"] == "error") {
                    self.typeOfAnswers.append(2)
                    self.answersArray.append(typeOfAnswer.what.rawValue)
                    self.collectionView.reloadData()
                }
                else if (json["content"] == "negative") {
                    self.typeOfAnswers.append(2)
                    self.answersArray.append(typeOfAnswer.angry.rawValue)
                    self.collectionView.reloadData()
                }
                else {
                    print("normal response")
                }
            }
            if response.result.isFailure == true {
                print("URL", "http://localhost:8000/api/" + url)
                print(response)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return answersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch typeOfAnswers[indexPath.row] {
        
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MessageCollectionViewCell
            
            cell.labelMsg.text = answersArray[indexPath.row]
            cell.colorView.layer.cornerRadius = 10
            
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "standardCellBot", for: indexPath) as! StandardBotCollectionViewCell
            
            cell.labelMsg.text = answersArray[indexPath.row]
            cell.colorView.layer.cornerRadius = 10
            
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellBot", for: indexPath) as! BotCollectionViewCell
            
            cell.labelMsg.text = answersArray[indexPath.row]
            cell.colorView.layer.cornerRadius = 10
            
            return cell
        }
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        
        let content : String = textField.text!
        textField.text = ""
        
        let parameters : Parameters = [
            "content": content
        ]
        typeOfAnswers.append(0)
        answersArray.append(content)
        collectionView.reloadData()
        self.myQuestion = true
        sendQuestion(url: "query", pam: parameters)
        return true
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
