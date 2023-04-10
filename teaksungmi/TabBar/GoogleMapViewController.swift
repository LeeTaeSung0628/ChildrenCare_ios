import Foundation
import UIKit
import GoogleMaps
import CoreLocation
import MaterialComponents
import Realm
import RealmSwift
import SwiftUI
import ARCL
import ARKit
import Firebase
import UserNotifications
import NotificationCenter
import FirebaseInstallations
import ImageSlideshow

class GoogleMapViewController: UIViewController, CLLocationManagerDelegate, ARSCNViewDelegate, GMSMapViewDelegate{
    
    var adminNumber :String = ""
    
    @IBOutlet weak var mapSubView: UIView!
    @IBOutlet weak var arView: UIView!
    
    var sceneLocationView = SceneLocationView()
    let floatingButton = MDCFloatingButton()
    let floatingButton1 = MDCFloatingButton(shape: .mini)
    let realm = try! Realm()
    var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    let progressDialog:ProgressDialogView = ProgressDialogView()
    let UUID = UIDevice.current.identifierForVendor?.uuidString
    var str_latitude : String = ""
    var str_longitude : String = ""
    let IP_ADDRESS = (Value.sharedInstance().IP_ADDRESS)
    var nodeArray: [SCNNode] = []//스템프 노드 배열
    var stampLocInout:Int = 0//stamp 위치판단
    var firstStamp:Int = 0 // 처음 그리는건지 판단
    var firstStamp1:Int = 0
    var firstStamp2:Int = 0
    var firstStamp3:Int = 0
    var name :String = ""
    //지도에 추가할 폴리곤과 라인
    var Fpolyline = GMSPolyline(path: nil)
    var Fpolygon = GMSPolygon(path: nil)
    //폴리라인 처음좌표를 저장하기 위함
    var ex_la:Double = 0.0
    var ex_lon:Double = 0.0
    var rect = GMSMutablePath()
    var Fname: String = ""//친구리스트에서 터치된 이름
    var FmarkerIndex: Int = 0//친구리스트에서 터치된 인덱스
    var Fmarker = GMSMarker()//친구마커
    var findmarkerPosition = CLLocationCoordinate2D()//선택된 친구 위치
    var out_check_count :Int = 0
    var stamp_check_count :Int = 0
    
    
    // 폴리라인 마커 링크 리스트(포인터) 사용
    var markerList = LinkedList<GMSMarker>(head: Node(value: GMSMarker(position: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)) , next: nil))
    var mk2 = [GMSMarker]()
    //밖에 있는지 않에있는지 체크
    var inOutCheck:Bool = false
    // 튜토리얼 이미지
    let shopImageSlide = ImageSlideshow()
    
        override func viewDidLoad() {
            super.viewDidLoad()
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            mk2.append(GMSMarker(position: CLLocationCoordinate2D(latitude:1.1, longitude: 1.1)))
            
            
            //지도부분 테두리 색깔,선두께
            self.mapSubView.layer.borderWidth = 6.6
            self.mapSubView.layer.borderColor = UIColor(red: 0.882, green: 0.933, blue: 0.918, alpha: 1).cgColor
            
            //0,1 번째 노드는 삭제가 불가능 하기때문에 리스트의 헤드와 헤드.next 를 초기화 해준다.
            let marker2 = GMSMarker(position: CLLocationCoordinate2D(latitude:1.1, longitude: 1.1))
            
            markerList.append(Node(value: marker2 , next: nil))
            
            let realm = try! Realm()
            let savedMe = realm.objects(Me.self)
            name = savedMe[0].name
            
            //토큰 번호 서버로 넘기기
            insertToken()

            // MARK: - AR작동 부분 --------------
            
            //진북 보정
            sceneLocationView.moveSceneHeadingClockwise()
            sceneLocationView.moveSceneHeadingAntiClockwise()
            
            //동작
            sceneLocationView.run()
            arView.addSubview(sceneLocationView)
            sceneLocationView.frame = arView.bounds
            
            createAR()
            
           
            // MARK: - 지도작동 부분 --------------
            
           // if locationManager == nil {
                locationManager = CLLocationManager()
                // 거리 정확도 설정
                locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                // 업데이트 이벤트가 발생하기전 장치가 수평으로 이동해야 하는 최소 거리(미터 단위)
                locationManager.distanceFilter = 1
                // 앱이 suspend 상태일때 위치정보를 수신받는지에 대한 결정
                locationManager.allowsBackgroundLocationUpdates = true
                // location manager가 위치정보를 수신을 일시 중지 할수 있는지에 대한 결정
                locationManager.pausesLocationUpdatesAutomatically = true
                // 델리게이트 설정
                locationManager.delegate = self
                // 사용자에게 허용 받기 alert 띄우기
                locationManager.requestWhenInUseAuthorization()
                locationManager.requestAlwaysAuthorization()
                //자동으로 멈춤 방지
                locationManager.pausesLocationUpdatesAutomatically = false
                //백그라운드 설정
                locationManager.allowsBackgroundLocationUpdates = true
                locationManager.showsBackgroundLocationIndicator=true
                // 아이폰 설정에서의 위치 서비스가 켜진 상태라면
                if CLLocationManager.locationServicesEnabled() {
                    print("위치 서비스 On 상태")
                    locationManager.startUpdatingLocation() //위치 정보 받아오기 시작
                    locationManager.startMonitoringSignificantLocationChanges()
                    print(locationManager.location?.coordinate as Any)
                } else {
                    print("위치 서비스 Off 상태")
                }
            //}
            setFloatingButton_stamp()

            //지도 띄우기
            mapView = GMSMapView(frame: view.frame)
            mapSubView.addSubview(mapView)
            mapView.frame = mapSubView.bounds
            mapSubView.alpha = 1
        
            mapView.isMyLocationEnabled = true//내위치 따라다니게 하기(파란점)

            // 관리자번호 가져오기
            adminNumber = savedMe[0].admin
            
            // 관리자용 비밀번호 설정
            if(adminNumber == "0426")//관리자용 비밀번호를 " " 안에 넣어주세요 **
            {
                setFloatingButton()
            }

            //관리자용 플로팅 View 버튼 생성부
            func setFloatingButton() {
                let image = UIImage(systemName: "person")
                floatingButton.sizeToFit()
                floatingButton.translatesAutoresizingMaskIntoConstraints = false
                floatingButton.setImage(image, for: .normal)
                floatingButton.setImageTintColor(.white, for: .normal)
                floatingButton.backgroundColor = UIColor(Color(#colorLiteral(red: 0.730852209, green: 0.8209240846, blue: 0.7496752832, alpha: 1)))
                floatingButton.addTarget(self, action: #selector(tap), for: .touchUpInside)
                view.addSubview(floatingButton)
                view.addConstraint(NSLayoutConstraint(item: floatingButton, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 65))
                view.addConstraint(NSLayoutConstraint(item: floatingButton, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 15))
                
                }
            //스템프 확인용 플로팅 View 버튼 생성
            func setFloatingButton_stamp() {

                let image = UIImage(systemName: "star.circle")
                floatingButton1.sizeToFit()
                floatingButton1.translatesAutoresizingMaskIntoConstraints = false
                floatingButton1.setImage(image, for: .normal)
                floatingButton1.setImageTintColor(.white, for: .normal)
                floatingButton1.backgroundColor = UIColor(Color(#colorLiteral(red: 0.930852209, green: 0.6209240846, blue: 0.7496752832, alpha: 1)))
                floatingButton1.addTarget(self, action: #selector(tap_stamp), for: .touchUpInside)
                view.addSubview(floatingButton1)
                view.addConstraint(NSLayoutConstraint(item: floatingButton1, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -680))
                view.addConstraint(NSLayoutConstraint(item: floatingButton1, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: -12))

            }

            
        }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        
        let savedTuto = realm.objects(Me.self)
        let fstTuto = savedTuto[0]
        
        if fstTuto.MTutoN != "1" {
            showTuto()
        }
        
        requestGPSPermission()
        
        //Fname = ""
        mapView.clear()
        
        rect.removeAllCoordinates()
        
 
        Task.init{
            //서버로 받아온 친구들의 위치에 핀 꽂는 함수
            self.view.addSubview(progressDialog)
            showProgressDialog()
            await addFriendLocation()
            

            //집결 위치
            await addPoly()
            hideProgressDialog()

            if !Fname.isEmpty{
                mapView.selectedMarker = markerList.findNode(at: FmarkerIndex)?.value
                markerList.findNode(at: FmarkerIndex)?.value.snippet = "여기에요!"
                moveCamera(at: findmarkerPosition)
            }else{
                moveCamera(at: locationManager.location?.coordinate)
            }
        }
        
        //폴리곤 위치정보를 서버를 통해 가져온 후 완료버튼을 누르지 않았거나(첫번째 값과 마지막값이 다르거나 ) 핀의 개수가 3개 미만인 경우 그리지 않는다.
        Task.init{
            //집결위치 가져오기
            await addPoly2()
            // 이미 그려져 있던 구역 그리기
            //핀이 삼각형 이상이 되었는지 확인
            if rect.count() >= 4{
                //첫번째 값과 마지막값을 비교해 완료버튼을 눌렀는지 확인
                if String(rect.coordinate(at: rect.count()-1).longitude) == String(rect.coordinate(at: 0).longitude){
                    
                    Fpolyline.map = nil
                    Fpolyline = GMSPolyline(path: rect)
                    Fpolyline.strokeWidth = 3.0
                    Fpolyline.strokeColor = .darkGray
                    Fpolyline.geodesic = true
                    Fpolyline.map = mapView
                    
                    Fpolygon.map = nil
                    Fpolygon = GMSPolygon(path: rect)
                    Fpolygon.fillColor = UIColor(displayP3Red: 0, green: 200/255, blue: 0, alpha: 0.1)
                    Fpolygon.map = mapView
                    
                }
                else{
                    Fpolygon.map = nil
                    Fpolyline.map = nil
                    rect.removeAllCoordinates()
                }
            }
            else{
                Fpolygon.map = nil
                Fpolyline.map = nil
                rect.removeAllCoordinates()
            }
        }
    
    }
    
    
    //뷰 원형처리
    override func viewDidLayoutSubviews() {
        
        mapSubView.layer.cornerRadius = 175
        mapSubView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
       // mapSubView.layer.cornerRadius = mapSubView.frame.width / 2 원만들기
    }
    
    
    // 플로팅 버튼 터치이벤트
    @objc func tap(_ sender: Any) {
        let adminStoryboard = UIStoryboard.init(name : "admin", bundle : nil)
        guard let adminView = adminStoryboard.instantiateViewController(identifier: "admin") as? adminViewController else {return}
        adminView.modalPresentationStyle = UIModalPresentationStyle.fullScreen

        self.present(adminView, animated: true, completion: nil)
        self.navigationController?.pushViewController(adminView, animated: true)
  
    }
    // 스템프 플로팅 버튼 터치이벤트
    @objc func tap_stamp(_ sender: Any) {
        let MainStoryboard = UIStoryboard.init(name : "Main", bundle : nil)
        guard let StampView = MainStoryboard.instantiateViewController(identifier: "StampOK") as? StampOK else {return}
        //StampView.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        
        self.present(StampView, animated: true, completion: nil)
        self.navigationController?.pushViewController(StampView, animated: true)
  
    }
    
    //-=--==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-==-=-=-=--=-=-=-=-==-=--==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    // MARK: MAP 함수
  
    //주기적으로 내 위치를 받아오는 함수
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let location = locations.first
        let myla: Double = location!.coordinate.latitude
        let mylon: Double = location!.coordinate.longitude
        let myposition = CLLocationCoordinate2D(latitude: myla, longitude: mylon)
        
        rect.removeAllCoordinates()
        
        //폴리곤 위치정보를 서버를 통해 가져온 후 완료버튼을 누르지 않았거나(첫번째 값과 마지막값이 다르거나 ) 핀의 개수가 3개 미만인 경우 그리지 않는다.
        Task.init{

            //폴리곤 위치 가져오기
            await addPoly2()
            await addFriendLocation()
            // 이미 그려져 있던 구역 그리기
            //[][][][][][]][[]][][]][[]][[][]][][][][]][[]][[]][][][][
            //첫번째 값과 마지막값을 비교해 완료버튼을 눌렀는지 확인
            if rect.count() >= 4{

                if String(rect.coordinate(at: rect.count()-1).longitude) == String(rect.coordinate(at: 0).longitude){
                    
                    Fpolyline.map = nil
                    Fpolyline = GMSPolyline(path: rect)
                    Fpolyline.strokeWidth = 3.0
                    Fpolyline.strokeColor = .darkGray
                    Fpolyline.geodesic = true
                    Fpolyline.map = mapView
                    
                    Fpolygon.map = nil
                    Fpolygon = GMSPolygon(path: rect)
                    Fpolygon.fillColor = UIColor(displayP3Red: 0, green: 200/255, blue: 0, alpha: 0.17)
                    Fpolygon.map = mapView
                    
                    if Fpolygon.contains(coordinate: myposition){

                        inOutCheck = true
                    }
                    else{
        
                        if inOutCheck == true{
                            showToast(message: "지정된 구역을 벗어났습니다!!")
                            
                            out_check_count = out_check_count + 1
                            
                            if out_check_count >= 3{
                                pushNoti()
                                out_check_count = 0
                                inOutCheck = false
                            }
                        }
                    }
                }
                else{
                    Fpolygon.map = nil
                    Fpolyline.map = nil
                    rect.removeAllCoordinates()
                }
            }
            else {
                Fpolygon.map = nil
                Fpolyline.map = nil
                rect.removeAllCoordinates()
            }
            
            
            if !Fname.isEmpty{
                if markerList.findNode(at: FmarkerIndex)?.value.position.latitude != 0.0{
                    mapView.selectedMarker = markerList.findNode(at: FmarkerIndex)?.value
                    markerList.findNode(at: FmarkerIndex)?.value.snippet = "여기에요!"
                    moveCamera(at: findmarkerPosition)
                }
                else{
                    showToast(message: "위치를 찾을 수 없습니다!!")
                    _ = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                        self.dismiss(animated: true)
                    }
                }
            }
        }
        
        
        if let location = locations.first {
            str_latitude = String(location.coordinate.latitude)
            str_longitude = String(location.coordinate.longitude)
            let request = NSMutableURLRequest(url: NSURL(string: "http://\(IP_ADDRESS)/insert.php")! as URL)
            request.httpMethod = "POST"
            let postString = "UUID=\(String(describing: UUID!))&str_latitude=\(str_latitude)&str_longitude=\(str_longitude)"
            request.httpBody = postString.data(using: String.Encoding.utf8)
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in

                if error != nil {
                    print("error=\(String(describing: error))")
                    return
                }
            }
            task.resume()
        }
        //ar 범위 확인 폴리곤
        let path = GMSMutablePath() // ar_라인 정문
        path.addLatitude(37.215248, longitude: 126.952592)
        path.addLatitude(37.215165, longitude: 126.952382)
        path.addLatitude(37.214959, longitude: 126.952428)
        path.addLatitude(37.215090, longitude: 126.952746)
        path.addLatitude(37.215248, longitude: 126.952592)
        let path1 = GMSMutablePath() // ar_라인 도서관
        path1.addLatitude(37.213140, longitude: 126.952135)
        path1.addLatitude(37.212502, longitude: 126.951906)
        path1.addLatitude(37.212417, longitude: 126.952509)
        path1.addLatitude(37.212991, longitude: 126.952638)
        path1.addLatitude(37.213140, longitude: 126.952135)
        let path2 = GMSMutablePath() // ar_라인 학생회관
        
        path2.addLatitude(37.212696, longitude: 126.951443)
        path2.addLatitude(37.212078, longitude: 126.951097)
        path2.addLatitude(37.211927, longitude: 126.951714)
        path2.addLatitude(37.212376, longitude: 126.951998)
        path2.addLatitude(37.212696, longitude: 126.951443)
        //테스트용 집좌표
        /*path2.addLatitude(37.216073, longitude: 126.951955)
        path2.addLatitude(37.215997, longitude: 126.952076)
        path2.addLatitude(37.216272, longitude: 126.952222)
        path2.addLatitude(37.216454, longitude: 126.951974)
        path2.addLatitude(37.216073, longitude: 126.951955)*/
        let path3 = GMSMutablePath() // ar_라인 이공관
        path3.addLatitude(37.212192, longitude: 126.953186)
        path3.addLatitude(37.211842, longitude: 126.952746)
        path3.addLatitude(37.211511, longitude: 126.953186)
        path3.addLatitude(37.212016, longitude: 126.953585)
        path3.addLatitude(37.212192, longitude: 126.953186)
        
        //stamp 범위에 들어와 있는지
        if path.contains(coordinate: myposition, geodesic: true){
            stamp_check_count = stamp_check_count + 1
            
            if stamp_check_count >= 3
            {
                stampLocInout = 1
                _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                    self.createStamp()
                    self.stamp_check_count = 0
                }
            }
            
        }else{
            if path.contains(coordinate: myposition, geodesic: false){
                stampLocInout = 0
            }
        }
        if path1.contains(coordinate: myposition, geodesic: true) {
            stamp_check_count = stamp_check_count + 1
            
            if stamp_check_count >= 3
            {
                stampLocInout = 2
                _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                    self.createStamp()
                    self.stamp_check_count = 0
                }
            }
            
        }else{
            if path1.contains(coordinate: myposition, geodesic: false){
                stampLocInout = 0
            }
        }
        if path2.contains(coordinate: myposition, geodesic: true) {
            stamp_check_count = stamp_check_count + 1
            
            if stamp_check_count >= 3
            {
                stampLocInout = 3
                _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                    self.createStamp()
                    self.stamp_check_count = 0
                }
            }
            
        }else{
            if path2.contains(coordinate: myposition, geodesic: false){
                stampLocInout = 0
            }
        }
        if path3.contains(coordinate: myposition, geodesic: true) {
            stamp_check_count = stamp_check_count + 1
            
            if stamp_check_count >= 3
            {
                stampLocInout = 4
                _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                    self.createStamp()
                    self.stamp_check_count = 0
                }
            }

        }else{
            if path3.contains(coordinate: myposition, geodesic: false){
                stampLocInout = 0
            }
        }
    }
    
    func requestGPSPermission(){
          
          switch CLLocationManager.authorizationStatus() {
          case .authorizedAlways:
              print("GPS: 권한 항상")
          case .authorizedWhenInUse:
              print("GPS: 권한 사용할때만")
              setAuthAlertAction()
          case .restricted, .notDetermined:
              print("GPS: 아직 선택하지 않음")
              setAuthAlertAction()
          case .denied:
               print("GPS: 권한 없음")
              setAuthAlertAction()
          default:
              print("GPS: Default")
          }
      }
    func setAuthAlertAction(){
        let authAlertController: UIAlertController
        authAlertController = UIAlertController(title: "위치 항상허용 요청", message: "위치 권한을 항상 허용해야만 앱을 사용하실 수 있습니다.", preferredStyle: UIAlertController.Style.alert)
        let getAuthAction: UIAlertAction
        getAuthAction = UIAlertAction(title: "허용", style: UIAlertAction.Style.default, handler: { UIAlertAction in
            if let appSettings = URL(string: UIApplication.openSettingsURLString){
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        })
        let NogetAuthAction: UIAlertAction
        NogetAuthAction = UIAlertAction(title: "허용안함", style: UIAlertAction.Style.default, handler: {UIAlertAction in
            // 앱 강제 종료
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {exit(0)})
        })
        authAlertController.addAction(getAuthAction)
        authAlertController.addAction(NogetAuthAction)
        self.present(authAlertController, animated: true, completion: nil)
    }
    
    //카메라 위치이동
    func moveCamera(at coordinate: CLLocationCoordinate2D?) {
        
        guard let coordinate = coordinate else {
            return
        }
        
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 14.0)
        mapView.camera = camera
        
    }
    
    // 서버DB 측으로부터 friend테이블의 나의친구 리스트에 추가되었는 친구들의 위도 경도를 가져온다.
    func addFriendLocation() async{
        do{
            
            guard let url = URL(string: "http://\(IP_ADDRESS)/getMyFriend.php") else { fatalError("Missing URL") }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            let postString = "TO_FRIEND=\(String(describing: UUID!))"
            urlRequest.httpBody = postString.data(using: String.Encoding.utf8)
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            let friendLocations = json
            let friendLocation =  friendLocations["friend"] as? [[String: String]]
            
            //처음 초기화한 2개 값을 제외한 모든값 삭제
            if markerList.size() > 1
            {
                let i:Int = 2
                while i <= markerList.size(){
                    // 2번 인덱스 ( 3번째 값 ) 을 지우면 다음값이 2번 째 인덱스가 되므로 모든 2번 인덱스를 지운다,
                    markerList.findNode(at: i)?.value.map = nil
                    markerList.remove(at: i)
                }
            }
            for item in friendLocation ?? [] {
                if item["str_latitude"]! != "x"{ // 유효하지 않은 주소가 아닐때만!
                    let position = CLLocationCoordinate2D(latitude: Double(item["str_latitude"]!)!, longitude: Double(item["str_longitude"]!)!)
                    Fmarker = GMSMarker(position: position)
                    let fla: Double = position.latitude
                    let flon: Double = position.longitude
                    let Fposition = CLLocationCoordinate2D(latitude: fla, longitude: flon)
                   
                    if rect.count() >= 4 && String(rect.coordinate(at: rect.count()-1).longitude) == String(rect.coordinate(at: 0).longitude){
                        if rect.contains(coordinate: Fposition, geodesic: false) {
                            Fmarker.title = item["name"]!
                            Fmarker.icon = UIImage(named: "studentpin.png")
                            Fmarker.map = mapView
                            //링크 리스트로 연결
                            markerList.append(Node(value: Fmarker, next: nil))
                           
                        }
                        else{
                                Fmarker.title = item["name"]!
                                Fmarker.icon = UIImage(named: "Outstudentpin.png")
                                Fmarker.map = mapView
                                //링크 리스트로 연결
                                markerList.append(Node(value: Fmarker, next: nil))
                        }
                    }
                    else{
                        Fmarker.title = item["name"]!
                        Fmarker.icon = UIImage(named: "studentpin.png")
                        Fmarker.map = mapView
                        //링크 리스트로 연결
                        markerList.append(Node(value: Fmarker, next: nil))
                      
                    }
                }
                else{
                    Fmarker = GMSMarker(position: CLLocationCoordinate2D(latitude: Double(0.0), longitude: Double(0.0)))
                    Fmarker.title = item["위치가우효하지 않습니다."]
                    markerList.append(Node(value: Fmarker, next: nil))
                }
            }

            if !Fname.isEmpty{
                if markerList.size() >= FmarkerIndex{
                    findmarkerPosition = (markerList.findNode(at: FmarkerIndex)?.value.position)!
                }
                else{
                    showToast(message: "잠시 후에 다시 시도해주세요!")
                    _ = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                        self.dismiss(animated: true)
                    }

                }
            }
            
        }catch{
            //return "error"
        }
    }
    
    // 서버DB 측으로부터 friend테이블의 나의친구 리스트에 추가되었는 친구들의 위도 경도를 가져온다.
    func addPoly() async{
        do{
            guard let url = URL(string: "http://\(IP_ADDRESS)/getMyPoly.php") else { fatalError("Missing URL") }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            let friendLocations = json
            let friendLocation =  friendLocations["poly"] as? [[String: String]]
            for item in friendLocation ?? [] {
                let position = CLLocationCoordinate2D(latitude: Double(item["str_latitude"]!)!, longitude: Double(item["str_longitude"]!)!)
                let marker = GMSMarker(position: position)
                marker.title = "집합 위치"
                marker.icon = UIImage(named: "assemblepin.png")
                marker.snippet = ""
                marker.map = mapView
                
        }
        }catch{
            //return "error"
        }
    }
    
    // 서버측으로 부터 admin 뷰에서 그린 라인을 얻어온다
    func addPoly2() async{
        do{
            var checkFirstFun :Bool = false
            guard let url = URL(string: "http://\(IP_ADDRESS)/getMyPoly2.php") else { fatalError("Missing URL") }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            let friendLocations = json
            let friendLocation =  friendLocations["poly2"] as? [[String: String]]
            for item in friendLocation ?? [] {
                let position = CLLocationCoordinate2D(latitude: Double(item["str_latitude"]!)!, longitude: Double(item["str_longitude"]!)!)
                if checkFirstFun == false {
                    ex_la = position.latitude
                    ex_lon = position.longitude
                }
                rect.addLatitude(position.latitude, longitude: position.longitude)
                checkFirstFun = true
            }
                
        }catch{
            //return "error"
        }
    }
    //-=--==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-==-=-=-=--=-=-=-=-==-=--==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    // MARK: AR함수
    //스템프 생성
    @objc func createStamp(){
            if stampLocInout == 1{
                if firstStamp == 0{
                    //정문
                    let S1coordinate = CLLocationCoordinate2D(latitude: 37.215102, longitude: 126.952574)
                    let S1location = CLLocation(coordinate: S1coordinate, altitude: 50)
                    //ar이미지 추가
                    let S1image: UIImage? = UIImage(named:"stamp.png")!
                    
                    //노드생성
                    let S1annotationNode = LocationAnnotationNode(location: S1location, image: S1image!)
                    
                    sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: S1annotationNode)
                    nodeArray.append(S1annotationNode as SCNNode)
                    firstStamp = 1

                }
            }
        
            if stampLocInout == 2{
                if firstStamp1 == 0{
                    //Stamp2 도서관
                    let S2coordinate = CLLocationCoordinate2D(latitude: 37.212771, longitude: 126.952179)
                    let S2location = CLLocation(coordinate: S2coordinate, altitude: 70)
                    //ar이미지 추가
                    let S2image: UIImage? = UIImage(named:"stamp2.png")!
                    //노드생성
                    let S2annotationNode = LocationAnnotationNode(location: S2location, image: S2image!)
                    sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: S2annotationNode)
                    nodeArray.append(S2annotationNode as SCNNode)
                    firstStamp1 = 1

                }
            }
        
            if stampLocInout == 3{
                if firstStamp2 == 0{
                    //Stamp3 학생회관
                    let S3coordinate = CLLocationCoordinate2D(latitude: 37.212143, longitude: 126.951641)
                    let S3location = CLLocation(coordinate: S3coordinate, altitude: 85)
                    //ar이미지 추가
                    let S3image: UIImage? = UIImage(named:"stamp3.png")!
                    //노드생성
                    let S3annotationNode = LocationAnnotationNode(location: S3location, image: S3image!)
                    sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: S3annotationNode)
                    nodeArray.append(S3annotationNode as SCNNode)
                    firstStamp2 = 1

                }
            }
        
            if stampLocInout == 4{
                if firstStamp3 == 0{
                    //Stamp4 이공관
                    let S4coordinate = CLLocationCoordinate2D(latitude: 37.211916, longitude: 126.953023)
                    let S4location = CLLocation(coordinate: S4coordinate, altitude: 80)
                    //ar이미지 추가
                    let S4image: UIImage? = UIImage(named:"stamp4.png")!
                    
                    //노드생성
                    let S4annotationNode = LocationAnnotationNode(location: S4location, image: S4image!)
                    sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: S4annotationNode)
                    
                    nodeArray.append(S4annotationNode as SCNNode)
                    firstStamp3 = 1

                }
            }
        
    }
    
    @objc func createAR() {

        // 함수호출형으로 텍스트 박스 ar노드 생성
        buildDemoData().forEach {
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0)
        }
        
        
    }

    //노드 생성
    func buildDemoData() -> [LocationAnnotationNode] {
        var nodes: [LocationAnnotationNode] = []

        // 텍스트 박스 ar 만들기
        let maingate = CATextLayer()
        maingate.frame = CGRect(x: 0, y: 0, width: 100, height: 45)
        maingate.cornerRadius = 4
        maingate.fontSize = 30
        maingate.alignmentMode = .center
        maingate.foregroundColor = UIColor(Color(#colorLiteral(red: 0.8280085325, green: 0.828943193, blue: 0.8202095628, alpha: 1))).cgColor
        maingate.backgroundColor = UIColor.darkGray.cgColor
        maingate.borderColor = UIColor.white.cgColor
        maingate.borderWidth = 1
            maingate.string = "정문\n"

        let mainG = buildLayerNode(latitude: 37.215102, longitude: 126.952574, altitude: 60, layer: maingate)
        nodes.append(mainG)
        
        let lib = CATextLayer()
        lib.frame = CGRect(x: 0, y: 0, width: 110, height: 45)
        lib.cornerRadius = 4
        lib.fontSize = 30
        lib.alignmentMode = .center
        lib.foregroundColor = UIColor(Color(#colorLiteral(red: 0.8280085325, green: 0.828943193, blue: 0.8202095628, alpha: 1))).cgColor
        lib.backgroundColor = UIColor.darkGray.cgColor
        lib.borderColor = UIColor.white.cgColor
        lib.borderWidth = 1
            lib.string = "도서관\n"
        
        let LI = buildLayerNode(latitude: 37.212771, longitude: 126.952179, altitude: 80, layer: lib)
        nodes.append(LI)
        
        let stu = CATextLayer()
        stu.frame = CGRect(x: 0, y: 0, width: 110, height: 45)
        stu.cornerRadius = 4
        stu.fontSize = 30
        stu.alignmentMode = .center
        stu.foregroundColor = UIColor(Color(#colorLiteral(red: 0.8280085325, green: 0.828943193, blue: 0.8202095628, alpha: 1))).cgColor
        stu.backgroundColor = UIColor.darkGray.cgColor
        stu.borderColor = UIColor.white.cgColor
        stu.borderWidth = 1
            stu.string = "학생회관\n"
        
        let ST = buildLayerNode(latitude: 37.212143, longitude: 126.951641, altitude: 80, layer: stu)
        nodes.append(ST)
        
        let sciengi = CATextLayer()
        sciengi.frame = CGRect(x: 0, y: 0, width: 100, height: 45)
        sciengi.cornerRadius = 4
        sciengi.fontSize = 30
        sciengi.alignmentMode = .center
        sciengi.foregroundColor = UIColor(Color(#colorLiteral(red: 0.8280085325, green: 0.828943193, blue: 0.8202095628, alpha: 1))).cgColor
        sciengi.backgroundColor = UIColor.darkGray.cgColor
        sciengi.borderColor = UIColor.white.cgColor
        sciengi.borderWidth = 1

            sciengi.string = "이공관\n"
        
        let SE = buildLayerNode(latitude: 37.211916, longitude: 126.953023, altitude: 90, layer: sciengi)
        nodes.append(SE)
        
        let gyung = CATextLayer()
        gyung.frame = CGRect(x: 0, y: 0, width: 100, height: 45)
        gyung.cornerRadius = 4
        gyung.fontSize = 30
        gyung.alignmentMode = .center
        gyung.foregroundColor = UIColor(Color(#colorLiteral(red: 0.8280085325, green: 0.828943193, blue: 0.8202095628, alpha: 1))).cgColor
        gyung.backgroundColor = UIColor.darkGray.cgColor
        gyung.borderColor = UIColor.white.cgColor
        gyung.borderWidth = 1
            gyung.string = "경영관\n"
        
        let GY = buildLayerNode(latitude: 37.213036, longitude: 126.953244, altitude: 90, layer: gyung)
        nodes.append(GY)
        
        return nodes

    }
 
    
    //노드 위치 틀
    func buildNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                   altitude: CLLocationDistance, imageName: String) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        let image = UIImage(named: imageName)!
        return LocationAnnotationNode(location: location, image: image)
    }
    
     //- 텍스트박스
    func buildLayerNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                        altitude: CLLocationDistance, layer: CALayer) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        return LocationAnnotationNode(location: location, layer: layer)
    }
    
    //scene노드 터치 이벤트
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
   {
    let touch = touches.first!
    let location = touch.location(in: sceneLocationView)
    let hitResults = sceneLocationView.hitTest(location, options: nil)
       
    if let result = hitResults.first {
        //handleTouchFor(node: result.node)
        annotationNodeTouched(node: result.node as! AnnotationNode)
        
   }
    // 텍스트 박스,
    func handleTouchFor(node: SCNNode) {
            //showToast(message: "화장실 있음")
            //print("텍스트박스 터치")
    }
  
    //스템프 터치이벤트
    func annotationNodeTouched(node: AnnotationNode){
        
        let Stamprealm = try! Realm()
        let stampR = Stamp()
        let Scount = Stamprealm.objects(Stamp.self)
        
        //스템프 이미지 터치시 데이터 저장
        if node.image == UIImage(named:"stamp.png")!{
            stampR.Stampname = "정문 스탬프"
            stampR.StampCount = 1
            try! Stamprealm.write{
                Stamprealm.add(stampR)
            }
            let Stampname = stampR.Stampname
            print("정문 스탬프 저장!!",Stampname)
            showToast(message: Stampname+" 찍힘!!")
            let nodeA = nodeArray.last!
            nodeA.removeFromParentNode()
            nodeArray.removeAll()
            
        }
        else if node.image == UIImage(named:"stamp2.png")!{
            stampR.Stampname = "도서관 스탬프"
            stampR.StampCount = 2
            try! Stamprealm.write{
                Stamprealm.add(stampR)
            }
            let Stampname = stampR.Stampname
            print("도서관 스탬프 저장!!",Stampname)
            showToast(message: Stampname+" 찍힘!!")
            let nodeA = nodeArray.last!
            nodeA.removeFromParentNode()
            nodeArray.removeAll()
        }
        else if node.image == UIImage(named:"stamp3.png")!{
            stampR.Stampname = "학생회관 스탬프"
            stampR.StampCount = 3
            try! Stamprealm.write{
                Stamprealm.add(stampR)
            }
            let Stampname = stampR.Stampname
            print("학생회관 스탬프 저장!!",Stampname)
            showToast(message: Stampname+" 찍힘!!")
            let nodeA = nodeArray.last!
            nodeA.removeFromParentNode()
            nodeArray.removeAll()
        }
        else if node.image == UIImage(named:"stamp4.png")!{
            stampR.Stampname = "이공관 스탬프"
            stampR.StampCount = 4
            try! Stamprealm.write{
                Stamprealm.add(stampR)
            }
            let Stampname = stampR.Stampname
            print("이공관 스탬프 찍힘!!",Stampname, nodeArray)
            showToast(message: Stampname+" 찍힘!!")
            let nodeA = nodeArray.last!
            nodeA.removeFromParentNode()
            nodeArray.removeAll()
        }
        if Scount.count == 4{
            // 서버로 정보 보내기!
            Task.init{
                await pushCompleteNoti()
            }
        }

     }
   }
    
    
    // 서버에 토큰 보내기
    func insertToken(){
        Messaging.messaging().token { token, error in
            let IP_ADDRESS_2 = (Value.sharedInstance().IP_ADDRESS)
            let UUID_2 = UIDevice.current.identifierForVendor?.uuidString
                    if let error = error {
                        print("Error fetching remote instance ID: \(error)")
                    } else if token != nil {
                        let request = NSMutableURLRequest(url: NSURL(string: "http://\(IP_ADDRESS_2)/insertToken.php")! as URL)
                        request.httpMethod = "POST"
                        let postString = "UUID=\(String(describing: UUID_2!))&Token=\(String(describing: token!))"
                        request.httpBody = postString.data(using: String.Encoding.utf8)
                           
                        let task = URLSession.shared.dataTask(with: request as URLRequest) {
                            data, response, error in
                            print("인서트 토큰 실행")
                            if error != nil {
                                print("error=\(String(describing: error))")
                                return
                            }
                        }
                                task.resume()
                       }
        }
    }
    
    
    // 서버측에 uuid와 이름을 보내기
    func pushNoti(){
            let request = NSMutableURLRequest(url: NSURL(string: "http://\(IP_ADDRESS)/push.php")! as URL)
            request.httpMethod = "POST"
            let postString = "UUID=\(String(describing: UUID!))&name=\(name)"
            request.httpBody = postString.data(using: String.Encoding.utf8)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                        data, response, error in
                        if error != nil {
                            print("error=\(String(describing: error))")
                            return
                        }
                    }
                    task.resume()
            
    }
    
    // 스탬프 완성시 서버에 정보 알려주기
    func pushCompleteNoti(){
            let request = NSMutableURLRequest(url: NSURL(string: "http://\(IP_ADDRESS)/pushComplete.php")! as URL)
            request.httpMethod = "POST"
            let postString = "UUID=\(String(describing: UUID!))&name=\(name)"
            request.httpBody = postString.data(using: String.Encoding.utf8)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                        data, response, error in
                        if error != nil {
                            print("error=\(String(describing: error))")
                            return
                        }
                    }
                    task.resume()
            
    }
    
    // MARK: - 부가기능
    
    func showToast(message : String) {
           let width_variable:CGFloat = 10
           let toastLabel = UILabel(frame: CGRect(x: width_variable, y: self.view.frame.size.height-450, width: view.frame.size.width-2*width_variable, height: 35))
           // 뷰가 위치할 위치를 지정해준다. 여기서는 아래로부터 100만큼 떨어져있고, 너비는 양쪽에 10만큼 여백을 가지며, 높이는 35로
           toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
           toastLabel.textColor = UIColor.white
           toastLabel.textAlignment = .center;
           toastLabel.font = UIFont(name: "BM JUA_OTF", size: 20.0)
           toastLabel.text = message
           toastLabel.alpha = 1.0
           toastLabel.layer.cornerRadius = 10;
           toastLabel.clipsToBounds  =  true
           self.view.addSubview(toastLabel)
           UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
               toastLabel.alpha = 0.0
           }, completion: {(isCompleted) in
               toastLabel.removeFromSuperview()
           })
       }
    
    func showProgressDialog() {
        self.progressDialog.show()
        
    }
    func hideProgressDialog() {
        self.progressDialog.hide()
        
    }
    
    
    func showTuto() {
        let TTStoryboard = UIStoryboard.init(name : "Tutorial", bundle : nil)
        guard let TTView = TTStoryboard.instantiateViewController(identifier: "TMVC") as? TutoriralViewControler else {return}
        self.present(TTView, animated: true, completion: nil)
    }
        
    
    
}
