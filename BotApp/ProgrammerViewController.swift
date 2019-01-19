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
    
    var typeOfAnswers = [Int]()
    var answersArray = [String]()
    var timer = Timer()
    var latest = ""
    
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
        getMessages(url: "last-question")
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounting), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return answersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch typeOfAnswers[indexPath.row] {
            
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MessageCollectionViewCell
            cell.colorView.layer.cornerRadius = 10
            
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "programmerCell", for: indexPath) as! ProgrammerCollectionViewCell
            cell.colorView.layer.cornerRadius = 10
            
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MessageCollectionViewCell
            cell.colorView.layer.cornerRadius = 10
            
            return cell
        }
    }
    
    @objc func updateCounting(){
        getMessages(url: "last-question")
    }
    
    func getMessages(url: String) {
        Alamofire.request("http://localhost:8000/api/" + url, method: .post).responseJSON { response in
            response.result.ifSuccess {
                let json = JSON(response.result.value!)
                if(json["created_at"].stringValue != self.latest && json["is_dev"].intValue == 1) {
                    self.latest = json["created_at"].stringValue
                    
                    self.typeOfAnswers.append(json["is_dev"].intValue)
                    self.answersArray.append(json["content"].stringValue)
                    self.collectionView.reloadData()
                }
            }
            if response.result.isFailure == true {
                print("URL", "http://localhost:8000/api/" + url)
                print(response)
            }
        }
    }
    
    func saveQuestion(pam: Parameters, url: String) {
        Alamofire.request("http://localhost:8000/api/" + url, method: .post).responseJSON { response in
            response.result.ifSuccess {
                let json = JSON(response.result.value!)
                print(json)
            }
            if response.result.isFailure == true {
                print("URL", "http://localhost:8000/api/" + url)
                print(response)
            }
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
        saveQuestion(pam: parameters, url: "question-user")
        return true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }
}
