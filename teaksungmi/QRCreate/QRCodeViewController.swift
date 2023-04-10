//
//  QRCodeViewController.swift
//  teaksungmi
//
//  Created by 김유미 on 2022/01/12.
//

import Foundation
import UIKit
import RealmSwift

class QRCodeViewController: UIViewController {

    @IBOutlet weak var qrcodeView: UIView!

    let uuid :String? = UIDevice.current.identifierForVendor?.uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let frame = CGRect(origin: .zero, size: qrcodeView.frame.size)
        let qrcode = QRCodeView(frame: frame)
        
        let realm = try! Realm()
        let saveMy = realm.objects(Me.self)
        let myName = saveMy[0].name
        let myage = saveMy[0].age
        let mygrade = saveMy[0].grade
        let myclassN = saveMy[0].classN
        let mysung = saveMy[0].sung
        let myphoneN = saveMy[0].phoneN
        let myPphoneN = saveMy[0].PphonN

        
        let combining = "\(uuid!)나눔\(myName)나눔\(myage)나눔\(mygrade)나눔\(myclassN)나눔\(mysung)나눔\(myphoneN)나눔\(myPphoneN)"
        print(combining)
        // UUid 문자열을 data 로 가지는 qr code.
        qrcode.generateCode(combining, foregroundColor: #colorLiteral(red:0 , green: 0, blue: 0, alpha: 1), backgroundColor: #colorLiteral(red:1 , green: 1, blue:1 , alpha: 1))

        qrcodeView.addSubview(qrcode)
    }
    
       
}
