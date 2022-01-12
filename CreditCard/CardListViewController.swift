//
//  CardListViewController.swift
//  CreditCard
//
//  Created by Terry on 2022/01/10.
//

import UIKit
import Kingfisher
import FirebaseDatabase
import FirebaseFirestore

class CardListViewController: UITableViewController {
    
    var creditCardList: [CreditCard] = []
    //    var ref: DatabaseReference! // Firebase Realtime Database
    var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UITableView Cell Register
        let nibName = UINib(nibName: "CardListCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "CardListCell")
        
        //        실시간 데이터베이스 읽기
        //        ref = Database.database().reference()
        //        ref.observe(.value){ snapshot in
        //            //snapshot value 는 [String:[String:Any]] 형태의 딕셔너리 타입
        //
        //            guard let value = snapshot.value as? [String:[String:Any]] else { return }
        //
        //            do{
        //
        //                let jsonData = try JSONSerialization.data(withJSONObject: value) //json으로 포맷으로 변환
        //                let cardData = try JSONDecoder().decode([String : CreditCard].self, from: jsonData)
        //                let cardList = Array(cardData.values)
        //                self.creditCardList = cardList.sorted { $0.rank < $1.rank }
        //
        //                DispatchQueue.main.async {
        //                    self.tableView.reloadData()
        //                }
        //            } catch let error {
        //                print("ERROR JSON parsing \(error.localizedDescription)")
        //            }
        //
        //        }
        
        //Firestore 읽기
        db.collection("creditCardList").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("ERROR Firebase fetching document \(String(describing: error))")
                return
            }
            self.creditCardList = documents.compactMap { doc -> CreditCard? in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: doc.data(), options: [])
                    let creditCard = try JSONDecoder().decode(CreditCard.self, from: jsonData)
                    return creditCard
                }catch {
                    print("ERROR JSON Parsing \(error)")
                    return nil
                }
            }.sorted{ $0.rank < $1.rank}
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creditCardList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardListCell", for: indexPath) as? CardListCell else { return UITableViewCell() }
        
        cell.rankLabel.text =  "\(creditCardList[indexPath.row].rank)위"
        cell.promotionLabel.text = "\(creditCardList[indexPath.row].promotionDetail.amount)만원 증정"
        cell.cardNameLabel.text = "\(creditCardList[indexPath.row].name)"
        
        let imageURL = URL(string: creditCardList[indexPath.row].cardImageURL)
        cell.cardImageView.kf.setImage(with: imageURL)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //상세화면 전달
        let sb = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let detailViewController = sb.instantiateViewController(withIdentifier: "CardDetailViewController") as? CardDetailViewController else { return }
        detailViewController.promotionDetail = creditCardList[indexPath.row].promotionDetail
        self.show(detailViewController, sender: nil )
        
        //fireBase 값 수정 방법_Option1
        //        let cardID = creditCardList[indexPath.row].id
        //        ref.child("Item\(cardID)/isSelected").setValue(true)
        
        //fireBase 값 수정 방법_Option2
        //        ref.queryOrdered(byChild: "id").queryEqual(toValue: cardID).observe(.value) { [weak self] snapshot in
        //            guard let self = self ,
        //                  let value = snapshot.value as? [String:[String:Any]],
        //                  let key = value.keys.first  else { return }
        //            self.ref.child("\(key)/isSelected").setValue(true)
        //        }
        
        //       Firebase 쓰기
        //       optin 1 (databased의 컬렉션 경로를 아는경우 )
        let cardID = creditCardList[indexPath.row].id
//        db.collection("creditCardList").document("card\(cardID)").updateData(["isSelected": true])
        
        //        option 2 (databse의 컬렉션 경로를 모를 경우)
        db.collection("creditCardList").whereField("id", isEqualTo: cardID).getDocuments { snapshot, error in
            //snapshot은 배열로 전달
            guard let document = snapshot?.documents.first else {
                print("ERROR Firestore fetching docment")
                return
            }
            document.reference.updateData(["isSelected": true])
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //실시간 데이터베이스 삭제
            //fireBase Database value remove Option1
            //            let cardID = creditCardList[indexPath.row].id
            //            ref.child("Item\(cardID)").removeValue()
            
            //fireBase Database value remove Option2
            //            ref.queryOrdered(byChild: "id").queryEqual(toValue: cardID).observe(.value) { [weak self] snapshot in
            //                guard let self = self,
            //                      let value = snapshot.value as? [String:[String:Any]],
            //                      let key = value.keys.first else { return }
            //
            //                self.ref.child(key).removeValue()
            //            }
            
            //firestore 삭제
            //option 1 (데이터의 경로를 알고 있을때)
            let cardID = creditCardList[indexPath.row].id
//            db.collection("creditCardList").document("card\(cardID)").delete()
            
            //option 2 (데이터의 경로를 모르고 있을때)
            db.collection("creditCardList").whereField("id", isEqualTo: cardID).getDocuments { snapshot, error in
                guard let document = snapshot?.documents.first else {
                    print("ERROR Firestore fetching document")
                    return
                }
                document.reference.delete()
            }
        }
    }
}
