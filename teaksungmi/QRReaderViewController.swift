import UIKit
import AVFoundation
import RealmSwift
import MaterialComponents
import SwiftUI

class QRReaderViewController: UIViewController {
    
    let floatingButton = MDCFloatingButton()
    
    let IP_ADDRESS = (Value.sharedInstance().IP_ADDRESS)
    let TO_FRIEND = UIDevice.current.identifierForVendor?.uuidString
    var FROM_FRIEND : String? = nil
    var name: String? = nil
    let progressDialog:ProgressDialogView = ProgressDialogView()
    @IBOutlet var guideText: UILabel!
    @IBOutlet weak var readerView: UIView!
    //  실시간 캡처를 수행하기 위해서 AVCaptureSession 개체르 인스턴스화.
    private let captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        basicSetting()
        setFloatingButton()
        
        func setFloatingButton() {

            let image = UIImage(systemName: "delete.left.fill")
            floatingButton.sizeToFit()
            floatingButton.translatesAutoresizingMaskIntoConstraints = false
            floatingButton.setImage(image, for: .normal)
            floatingButton.setImageTintColor(.white, for: .normal)
            floatingButton.backgroundColor = .darkGray
            floatingButton.addTarget(self, action: #selector(tap), for: .touchUpInside)
            view.addSubview(floatingButton)
            view.addConstraint(NSLayoutConstraint(item: floatingButton, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 65))
            view.addConstraint(NSLayoutConstraint(item: floatingButton, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 15))
            
            }
        
    }
    
    
    
}
extension QRReaderViewController {
    
    private func basicSetting() {
        
        //  AVCaptureDevice : capture sessions 에 대한 입력(audio or video)과 하드웨어별 캡처 기능에 대한 제어를 제공하는 장치.
        //  즉, 캡처할 방식을 정하는 코드.
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
        
        //  시뮬레이터에서는 카메라를 사용할 수 없기 때문에 시뮬레이터에서 실행하면 에러가 발생한다.
        fatalError("No video device found")
        }
        do {

            //  적절한 inputs 설정
            //  AVCaptureDeviceInput : capture device 에서 capture session 으로 media 를 제공하는 capture input.
            //  즉, 특정 device 를 사용해서 input 를 초기화.
            let input = try AVCaptureDeviceInput(device: captureDevice)

            //  session 에 주어진 input 를 추가.
            captureSession.addInput(input)
            
            //  적절한 outputs 설정
            //  AVCaptureMetadataOutput : capture session 에 의해서 생성된 시간제한 metadata 를 처리하기 위한 capture output.
            //  즉, 영상으로 촬영하면서 지속적으로 생성되는 metadata 를 처리하는 output 이라는 말.
            let output = AVCaptureMetadataOutput()

            //  session 에 주어진 output 를 추가.
            captureSession.addOutput(output)
            
            print(output)

            //  AVCaptureMetadataOutputObjectsDelegate 포로토콜을 채택하는 delegate 와 dispatch queue 를 설정한다.
            //  queue : delegate 의 메서드를 실행할 큐이다. 이 큐는 metadata 가 받은 순서대로 전달되려면 반드시 serial queue(직렬큐) 여야 한다.
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            //  리더기가 인식할 수 있는 코드 타입을 정한다. 이 프로젝트의 경우 qr.
            output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

            //  카메라 영상이 나오는 layer 와 + 모양 가이드 라인을 뷰에 추가하는 함수 호출.
            setVideoLayer()
            setGuideCrossLineView()
            
            //  startRunning() 과 stopRunning() 로 흐름 통제
            //  input 에서 output 으로의 데이터 흐름을 시작
            captureSession.startRunning()
        }
        catch {
            print("error")
        }
    }

    //  카메라 영상이 나오는 layer 를 뷰에 추가
    private func setVideoLayer() {
        // 영상을 담을 공간.
        let videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // 카메라의 크기 지정
        videoLayer.frame = view.layer.bounds
        // 카메라의 비율지정
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(videoLayer)
    }

    //  + 모양 가이드라인을 뷰에 추가
    private func setGuideCrossLineView() {
        let guideCrossLine = UIImageView()
        guideCrossLine.image = UIImage(systemName: "cross.fill")
        //let bgColor :Color = Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1))
        guideCrossLine.tintColor = UIColor(Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)))
        guideCrossLine.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(guideCrossLine)
        NSLayoutConstraint.activate([
            guideCrossLine.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guideCrossLine.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            guideCrossLine.widthAnchor.constraint(equalToConstant: 30),
            guideCrossLine.heightAnchor.constraint(equalToConstant: 30)
            
        ])
        view.addSubview(guideText)

    }

}

extension QRReaderViewController: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        
        captureSession.stopRunning() //코드 인식시 멈춤
        if let metadataObject = metadataObjects.first {
            

            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject, let stringValue = readableObject.stringValue else {
                return
            }
            
            let pattern: String = "[0-9A-Z]{8}-[0-9A-Z]{4}-[0-9A-Z]{4}-[0-9A-Z]{4}-[0-9A-Z]{12}"

            //패턴값과 일치하지 않으면
            if stringValue.range(of: pattern, options: .regularExpression) == nil {

                let alert = UIAlertController(title: "알림", message: "다시찍어", preferredStyle: UIAlertController.Style.alert)
                
                
                

                let defaultAction =  UIAlertAction(title: "확인", style: UIAlertAction.Style.default){(_) in
                    // 버튼 클릭시 실행되는 코드
                    self.dismiss(animated: true)
                }
                //메시지 창 컨트롤러에 버튼 액션을 추가
                alert.addAction(defaultAction)
                
                self.present(alert, animated: false)
                
                
            }
            
            // 패턴값과 일치하면 저장하고 종료
                else{
                    
                    let friendDivision = stringValue.components(separatedBy: "나눔")
                    
                    let frienduuid :String? = friendDivision[0]
                    let friendname :String? = friendDivision[1]
                    let friendage :String? = friendDivision[2]
                    let friendgrade :String? = friendDivision[3]
                    let friendclassN :String? = friendDivision[4]
                    let friendsung :String? = friendDivision[5]
                    let friendphoneN :String? = friendDivision[6]
                    let friendPphoneN :String? = friendDivision[7]
                    
                    let saveMe = realm.objects(Friend.self)
                    
                    let filter = saveMe.filter("uuid == %FROM_FRIEND", frienduuid as Any)
                    
                    //중복된 uuid가 있을경우
                    if !(filter.isEmpty) {
                        self.floatingButton.removeFromSuperview() //버튼 삭제
                        //메세지 띄우기
                        let alert = UIAlertController(title: "오류", message: "이미 등록된 친구 입니다!", preferredStyle: UIAlertController.Style.alert)
                        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                            //확인시 엑션
                            self.dismiss(animated: true)
                        }
                        alert.addAction(okAction)
                        present(alert, animated: false, completion: nil)
                    }// 중복된 uuid가 없으면 추가
                    else{
                        
                        //서버에 보내는용
                        name = friendname!
                        FROM_FRIEND = frienduuid!
                        
                        
                        Task.init{
                            self.view.addSubview(progressDialog)
                            showProgressDialog()
                        
                            if await insertFriend() == "새로운 사용자를 추가했습니다."{//서버에도 추가되었을 때
                                 
                                let friend = Friend()
                                friend.uuid = frienduuid!
                                friend.name = friendname!
                                friend.age = friendage!
                                friend.grade = friendgrade!
                                friend.classN = friendclassN!
                                friend.sung = friendsung!
                                friend.phoneN = friendphoneN!
                                friend.PphonN = friendPphoneN!
                                print("친구정보 : ",friend)
                                try! realm.write {
                                    realm.add(friend)
                                }
                                

                                
                                print("실행이 된거임")
                                hideProgressDialog()
                                dismiss(animated: true, completion: nil)
                            }
                            else{//서버에 추가 못했을 때
                                print("실행이 안된거임")
                                
                                let alert = UIAlertController(title: "오류", message: "친구추가에 실패했습니다. 네트워크상태를 확인하세요.", preferredStyle: UIAlertController.Style.alert)
                                let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                                    //확인시 엑션
                                    self.dismiss(animated: true, completion: nil)
                                }
                                
                                hideProgressDialog()
                                alert.addAction(okAction)
                                present(alert, animated: false, completion: nil)
                            }
                        
                        }

                        
                    }
                }
            
        }
        
    }
    @objc func tap(_ sender: Any) {
        dismiss(animated: true)
    }
    
    //서버 DB.fiend 에 내uuid 및 친구uuid, 친구이름 전송
    func insertFriend() async -> String {
        
        do{
            guard let url = URL(string: "http://\(IP_ADDRESS)/insertFriend.php") else { fatalError("Missing URL") }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            let postString = "TO_FRIEND=\(String(describing: TO_FRIEND!))&FROM_FRIEND=\(String(describing: FROM_FRIEND!))&str_latitude=\(String("x"))&str_longitude=\(String("x"))&name=\(String(describing: name!))"
            urlRequest.httpBody = postString.data(using: String.Encoding.utf8)
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
        
            let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            
            return responseString! as String
        }catch{
            return "error"
        }
    }

    func showProgressDialog() {
        self.progressDialog.show()
        
    }
    func hideProgressDialog() {
        self.progressDialog.hide()
        
    }
    
}
