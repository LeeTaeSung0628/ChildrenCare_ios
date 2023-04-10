
import Foundation
import UIKit
import DropDown

class OptionsViewController : UIViewController {

    
    @IBOutlet weak var alarm: UISwitch!
    @IBOutlet var help: UIButton!
    let dropDown = DropDown()
    let progressDialog:ProgressDialogView = ProgressDialogView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        showProgressDialog()
        

        //현제 허용 상태 확인
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == UNAuthorizationStatus.authorized{self.alarm.isOn = true}
                else {self.alarm.isOn = false}
            }
        }
        
        hideProgressDialog()
    }
    
    @IBAction func alarm(_ sender: Any) {
        
        if alarm.isOn {
            let authAlertController: UIAlertController
            authAlertController = UIAlertController(title: "알림을 켜시겠습니까?", message: "아래 버튼을 누르면 설정으로 이동합니다!!", preferredStyle: UIAlertController.Style.alert)
            let getAuthAction: UIAlertAction
            getAuthAction = UIAlertAction(title: "이동~", style: UIAlertAction.Style.default, handler: { UIAlertAction in
                if let appSettings = URL(string: UIApplication.openSettingsURLString){
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            })
            let NogetAuthAction: UIAlertAction
            NogetAuthAction = UIAlertAction(title: "안함", style: UIAlertAction.Style.default, handler: {UIAlertAction in
                self.alarm.isOn = false
            })
            authAlertController.addAction(getAuthAction)
            authAlertController.addAction(NogetAuthAction)
            self.present(authAlertController, animated: true, completion: nil)
        }
        else{
            let authAlertController: UIAlertController
            authAlertController = UIAlertController(title: "알림을 끄시겠습니까?", message: "아래 버튼을 누르면 설정으로 이동합니다!!", preferredStyle: UIAlertController.Style.alert)
            let getAuthAction: UIAlertAction
            getAuthAction = UIAlertAction(title: "이동~", style: UIAlertAction.Style.default, handler: { UIAlertAction in
                if let appSettings = URL(string: UIApplication.openSettingsURLString){
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            })
            let NogetAuthAction: UIAlertAction
            NogetAuthAction = UIAlertAction(title: "안함", style: UIAlertAction.Style.default, handler: {UIAlertAction in
                self.alarm.isOn = true
            })
            authAlertController.addAction(getAuthAction)
            authAlertController.addAction(NogetAuthAction)
            self.present(authAlertController, animated: true, completion: nil)
        }
        
        
    }

    @IBAction func helpAction(_ sender: Any) {
        
        dropDown.dataSource = [" 메인화면 ", " 친구화면 ", " 관리자화면 "]
        dropDown.textFont = UIFont(name: "BM JUA_OTF", size: 25)!
        dropDown.cornerRadius = 15
        dropDown.anchorView = help
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            switch index {
                case 0:
                    let TTStoryboard = UIStoryboard.init(name : "Tutorial", bundle : nil)
                    guard let TTView = TTStoryboard.instantiateViewController(identifier: "TMVC") as? TutoriralViewControler else {return}
                    self.present(TTView, animated: true, completion: nil)
                    
                case 1:
                    let TTStoryboard = UIStoryboard.init(name : "Tutorial", bundle : nil)
                    guard let TTView = TTStoryboard.instantiateViewController(identifier: "FTMVC") as? FTutoriralViewControler else {return}
                    self.present(TTView, animated: true, completion: nil)
        
                case 2:
                    let TTStoryboard = UIStoryboard.init(name : "Tutorial", bundle : nil)
                    guard let TTView = TTStoryboard.instantiateViewController(identifier: "AdTMVC") as? AdTutoriralViewControler else {return}
                    self.present(TTView, animated: true, completion: nil)
                    
                default:
                    break
                    
            }
            
            self.dropDown.clearSelection()
        }
        
        dropDown.show()
        
    }
    
    func showProgressDialog() {
        self.progressDialog.show()
    }
    func hideProgressDialog() {
        self.progressDialog.hide()
    }
    
}
