
import UIKit
import JJFloatingActionButton
import MaterialComponents




class TabBarViewController: UITabBarController {
    
    let floatingButton = MDCFloatingButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
   
        let qrButton = JJFloatingActionButton()

        qrButton.addItem(title: "QR 인증", image: UIImage(systemName: "qrcode")?.withRenderingMode(.alwaysTemplate)) { item in

                
          // do something
            let QRStoryboard = UIStoryboard.init(name : "QRCreate", bundle : nil)
            guard let QRView = QRStoryboard.instantiateViewController(identifier: "QRVC") as? QRCodeViewController else {return}
            self.present(QRView, animated: true, completion: nil)
        }
        //qr 인증 버튼

        qrButton.addItem(title: "QR 스캔", image: UIImage(systemName: "qrcode.viewfinder")?.withRenderingMode(.alwaysTemplate)) { item in
          // do something
            
            let QRReaderStoryboard = UIStoryboard.init(name : "QRReader", bundle : nil)
            guard let QRReaderView = QRReaderStoryboard.instantiateViewController(identifier: "QRReader") as? QRReaderViewController else {return}
        
            //리더기에만 풀스크린으로 한다. 왜냐하면 풀스크린으로 안하면 기존에 있던 뷰가 생명주기가 돌지 않기떄문에 업데이트가 되지 않는다
            QRReaderView.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            
            self.present(QRReaderView, animated: true, completion: nil)
            
            
        }
        //qr 스캔 버튼
        


        view.addSubview(qrButton)
        //버튼을 뷰에 붙인다.
        qrButton.translatesAutoresizingMaskIntoConstraints = false
        qrButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        qrButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60).isActive = true

    }


}


