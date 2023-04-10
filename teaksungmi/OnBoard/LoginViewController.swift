
import UIKit
import RealmSwift
import SwiftUI
import CoreLocation

class LoginViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var admin: UITextField!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var grade: UITextField!
    @IBOutlet weak var classN: UITextField!
    @IBOutlet weak var sung: UITextField!
    @IBOutlet weak var phoneN: UITextField!
    @IBOutlet weak var PphoneN: UITextField!
    var textName: String?
    var textadmin: String?
    var textage: String?
    var textgrade: String?
    var textclassN: String?
    var textsung: String?
    var textphoneN: String?
    var textPphoneN: String?

    
    let realm = try! Realm()
    let uuid = UIDevice.current.identifierForVendor?.uuidString
    var locationManager = CLLocationManager()
    let scrollView = UIScrollView()
    let innerView = UIView()
    var keyHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDelegate()
        addDoneButtonToKeyboard()

        hideKeyboardTappedView()
        
        // 사용자에게 허용 받기 alert 띄우기
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        setKeyboardObserver()
        
        
    }
    
    func addDelegate(){
        name.delegate = self
        age.delegate = self
        sung.delegate = self
        grade.delegate = self
        classN.delegate = self
        phoneN.delegate = self
        PphoneN.delegate = self
        admin.delegate = self
    }
    
    func addDoneButtonToKeyboard() {
        age.addDoneButtonToKeyboard(myAction:  #selector(self.age.resignFirstResponder))
        grade.addDoneButtonToKeyboard(myAction:  #selector(self.grade.resignFirstResponder))
        classN.addDoneButtonToKeyboard(myAction:  #selector(self.classN.resignFirstResponder))
        phoneN.addDoneButtonToKeyboard(myAction:  #selector(self.phoneN.resignFirstResponder))
        PphoneN.addDoneButtonToKeyboard(myAction:  #selector(self.PphoneN.resignFirstResponder))
        admin.addDoneButtonToKeyboard(myAction:  #selector(self.admin.resignFirstResponder))
    }

    @IBAction func save(_ sender: Any) {
        textName = name.text?.trimmingCharacters(in: .whitespaces)
        textadmin = admin.text?.trimmingCharacters(in: .whitespaces)
        textage = age.text?.trimmingCharacters(in: .whitespaces)
        textgrade = grade.text?.trimmingCharacters(in: .whitespaces)
        textclassN = classN.text?.trimmingCharacters(in: .whitespaces)
        textsung = sung.text?.trimmingCharacters(in: .whitespaces)
        textphoneN = phoneN.text?.trimmingCharacters(in: .whitespaces)
        textPphoneN = PphoneN.text?.trimmingCharacters(in: .whitespaces)
        let meData = Me()
        meData.name = textName!
        meData.uuid = uuid!
        meData.admin = textadmin!
        meData.age = textage!
        meData.grade = textgrade!
        meData.classN = textclassN!
        meData.sung = textsung!
        meData.phoneN = textphoneN!
        meData.PphonN = textPphoneN!


        // Realm 에 저장하기
        try! realm.write {
            realm.add(meData)
        }
        
        let loginStoryboard = UIStoryboard.init(name : "Main", bundle : nil)
        guard let loginView = loginStoryboard.instantiateViewController(identifier: "Main") as? TabBarViewController else {return}

        //리더기에만 풀스크린으로 한다. 왜냐하면 풀스크린으로 안하면 기존에 있던 뷰가 생명주기가 돌지 않기떄문에 업데이트가 되지 않는다
        loginView.modalPresentationStyle = UIModalPresentationStyle.fullScreen

        self.present(loginView, animated: true, completion: nil)
       
        
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let vc = storyboard.instantiateViewController(withIdentifier: "Main") as! TabBarViewController
//                vc.modalPresentationStyle = .fullScreen
//                present(vc, animated: false, completion: nil)
        let savedMe = realm.objects(Me.self)
        print(savedMe)
        
    }
    
    private func hideKeyboardTappedView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
      
    }
    
}

extension UITextField: UITextFieldDelegate{

     func addDoneButtonToKeyboard(myAction:Selector?){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        doneToolbar.barStyle = UIBarStyle.default

         let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
         let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: myAction)
         
         
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)

        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
         
     }
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}





