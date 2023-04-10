

import Foundation

import Foundation
import UIKit
import RealmSwift
class OptionInfo: UIViewController{
    
    
    
   
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var grade: UILabel!
    @IBOutlet weak var classN: UILabel!
    @IBOutlet weak var sung: UILabel!
    @IBOutlet weak var phoneN: UILabel!
    @IBOutlet weak var PphoneN: UILabel!
    var i = 0


    override func viewDidLoad() {
        
        let realm = try! Realm()
        let savedMe = realm.objects(Me.self)
        name.text = savedMe[i].name
        age.text = savedMe[i].age
        grade.text = savedMe[i].grade
        classN.text = savedMe[i].classN
        sung.text = savedMe[i].sung
        phoneN.text = savedMe[i].phoneN
        PphoneN.text = savedMe[i].PphonN
    }
       
}
