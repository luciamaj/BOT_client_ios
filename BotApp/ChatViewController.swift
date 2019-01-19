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
import SDWebImage
import IHKeyboardAvoiding

class ChatViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var textField: UITextField!
    
    var typeOfAnswers = [Int]()
    var answersArray = [String]()
    
    enum typeOfAnswer : String {
        case angry = "You seem angry"
        case what = "I didn't get it"
    }
    
    var urlImg : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        textField.autocorrectionType = .no
        
        self.hideKeyboardWhenTappedAround()
        self.textField.delegate = self
        KeyboardAvoiding.avoidingView = self.view
    }
    
    public func sendQuestion(url: String, pam: Parameters) {        
        Alamofire.request("http://localhost:8000/api/" + url, method: .post, parameters: pam).responseJSON { response in
            response.result.ifSuccess {
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
                    self.typeOfAnswers.append(1)
                    self.answersArray.append(json["content"].stringValue)
                    self.urlImg = json["filename"].stringValue
                    self.collectionView.reloadData()
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
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellBot", for: indexPath) as! BotCollectionViewCell
            
            cell.colorView.layer.cornerRadius = 10
            cell.labelMsg.text = answersArray[indexPath.row]
            
            cell.codeImg.sd_setImage(with: URL(string: "http://localhost:8000/uploads/" + urlImg), placeholderImage: UIImage(named: "placeholder"))
            
            return cell
        case 2:
            print()
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
        sendQuestion(url: "query", pam: parameters)
        return true
    }
    
    @IBAction func goToPage(_ sender: Any) {
        print("i'm getting angry")
    }
}
