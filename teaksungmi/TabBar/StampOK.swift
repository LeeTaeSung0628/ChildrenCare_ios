
import Foundation
import UIKit
import RealmSwift

class StampOK: UIViewController{
    
    var stampPan : UIImage?
    var stampSuc : UIImage?
    var backColor = UIColor.white
    var ok1 = 0
    var ok2 = 0
    var ok3 = 0
    var ok4 = 0

    //UIColor(red: 0.7299663424, green: 0.7357957959, blue: 0.7255882621, alpha: 1)
    @IBOutlet weak var StampTam: UIImageView!
    @IBOutlet weak var StampCount: UILabel!
    @IBOutlet weak var stamp1: UIImageView!
    @IBOutlet weak var stamp2: UIImageView!
    @IBOutlet weak var stamp3: UIImageView!
    @IBOutlet weak var stamp4: UIImageView!
    override func viewDidLoad() {
        
        self.view.backgroundColor = backColor
        stampPan = UIImage(named: "stampPan.png")
        stampSuc = UIImage(named: "stampSuccess.png")
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        StampimageView()
        
    }
    
    func StampimageView(){
        
        let realm = try! Realm()
        let realmC = realm.objects(Stamp.self)
        let c = realmC.count
        let S = realmC.last?.Stampname
        StampTam.image = stampPan
        /*stamp1.image = stampSuc
        stamp2.image = stampSuc
        stamp3.image = stampSuc
        stamp4.image = stampSuc*/

        if S == "정문 스탬프" || ok1 == 1{
            if c == 4{
                StampCount.text = "스탬프를 완성했습니다!"
            }
            else {
                stamp1.image = stampSuc
                StampCount.text = "스탬프 "+String(c)+"개 찍음!"
                ok1 = 1
            }
        }
        if S == "도서관 스탬프" || ok2 == 1{
            if c == 4{
                StampCount.text = "스탬프를 완성했습니다!"
            }
            else {
                stamp2.image = stampSuc
                StampCount.text = "스탬프 "+String(c)+"개 찍음!"
                ok2 = 1
            }
        }
        if S == "학생회관 스탬프" || ok3 == 1{
            if c == 4{
                StampCount.text = "스탬프를 완성했습니다!"
            }
            else {
                stamp3.image = stampSuc
                StampCount.text = "스탬프 "+String(c)+"개 찍음!"
                ok3 = 1
            }
        }
        if S == "이공관 스탬프" || ok4 == 1{
            if c == 4{
                StampCount.text = "스탬프를 완성했습니다!"
            }
            else {
                stamp4.image = stampSuc
                StampCount.text = "스탬프 "+String(c)+"개 찍음!"
                ok4 = 1
            }
        }
        if c == 0{
            StampCount.text = "찍은 스탬프가 없네요ㅠ"
        }
        
        
    }
}
