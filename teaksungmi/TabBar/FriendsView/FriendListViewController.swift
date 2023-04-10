

import UIKit
import RealmSwift
import SwiftUI

class FriendListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    let IP_ADDRESS = (Value.sharedInstance().IP_ADDRESS)
    let TO_FRIEND = UIDevice.current.identifierForVendor?.uuidString
    var FROM_FRIEND : String?
    let progressDialog:ProgressDialogView = ProgressDialogView()
    
    
    override func viewWillAppear(_ animated: Bool) {
        tableUpdayte()
        
        let savedTuto = realm.objects(Me.self)
        let fstTuto = savedTuto[0]
        
        if fstTuto.FTutoN != "1" {
            showTuto()
        }
    }
       
    public func tableUpdayte() {
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        let friends = realm.objects(Friend.self)
        return friends.count

    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let realm = try! Realm()
        let friends = realm.objects(Friend.self)
        let stampC = realm.objects(Stamp.self)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as? CustomTableViewCell else { return UITableViewCell() }
        if  stampC.count == 4{
            cell.customLabel.text = friends[indexPath.row].name+" (스탬프 완료!)"
        }else{
            cell.customLabel.text = friends[indexPath.row].name
        }
        return cell

    }
    //친구 이름 클릭 이벤트
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let MainStoryboard = UIStoryboard.init(name : "Main", bundle : nil)
        let realm = try! Realm()
        let friends = realm.objects(Friend.self)
        guard let GoogleMapView = MainStoryboard.instantiateViewController(identifier: "googlemapView") as? GoogleMapViewController else {return}
        GoogleMapView.Fname = friends[indexPath.row].name
        GoogleMapView.FmarkerIndex = (indexPath.row+2)
        self.present(GoogleMapView, animated: true, completion: nil)
        self.navigationController?.pushViewController(GoogleMapView, animated: true)
     }
     //스와이프해서 삭제하기
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            // realm가져오기
            let realm = try! Realm()
            let savedPerson = realm.objects(Friend.self)
            FROM_FRIEND = savedPerson[indexPath.row].uuid
            Task.init{//비동기처리 해결
                self.view.addSubview(progressDialog)
                showProgressDialog()
                if await deleteFriend() == "삭제 완료!"{//서버에도 삭제되었을 때
                    if editingStyle == .delete {
                        //db에서 삭제
                        try! realm.write {
                            realm.delete(savedPerson[indexPath.row])
                        }
                        print(savedPerson)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    } else if editingStyle == .insert {}
                }
            else{//서버에 삭제 못했을 때
                let alert = UIAlertController(title: "오류", message: "친구삭제에 실패했습니다. 네트워크상태를 확인하세요.", preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                    //확인시 엑션
                }
                alert.addAction(okAction)
                present(alert, animated: false, completion: nil)
            }
                hideProgressDialog()
            }
            
        }
    func deleteFriend() async -> String {
        do{
            guard let url = URL(string: "http://\(IP_ADDRESS)/deleteFriend.php") else { fatalError("Missing URL") }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            let postString = "TO_FRIEND=\(String(describing: TO_FRIEND!))&FROM_FRIEND=\(String(describing: FROM_FRIEND!))"
            urlRequest.httpBody = postString.data(using: String.Encoding.utf8)
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
        
            let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            print(responseString!)
            return responseString! as String
        }catch{
            return "error"
        }
    }
    //테이블 삭제 코멘트 Delete에서 삭제로 바꾸기
        func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
            return "삭제"
        }
    //왼쪽으로 밀면 정보보기
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let complete = completeAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [complete])
    }
        
    //정보보기 클릭 이벤트
    func completeAction(at indexPath: IndexPath) -> UIContextualAction {
            let action = UIContextualAction(style: .destructive, title: "정보보기") { (action, view, success) in
                print("클릭클릭")
                
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "information") as? StudentInfo else {return}
                vc.i = indexPath.row
                self.present(vc, animated: true)
                
                success(true)
            }
            let bgColor :Color = Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)) // 컬러 코드로 뽑기용 Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1))
            action.backgroundColor = UIColor(Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)))
            return action
    }
    
  
    
    func showProgressDialog() {
        self.progressDialog.show()
    }
    func hideProgressDialog() {
        self.progressDialog.hide()
    }
    
    func showTuto() {
        let TTStoryboard = UIStoryboard.init(name : "Tutorial", bundle : nil)
        guard let TTView = TTStoryboard.instantiateViewController(identifier: "FTMVC") as? FTutoriralViewControler else {return}
        self.present(TTView, animated: true, completion: nil)
    }
}
