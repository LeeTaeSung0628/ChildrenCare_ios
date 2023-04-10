import Foundation
import UIKit
import GoogleMaps
import CoreLocation
import MaterialComponents
import RealmSwift
import SwiftUI
import GoogleMapsUtils

class adminViewController: UIViewController , CLLocationManagerDelegate, GMSMapViewDelegate{
    
    var mapView: GMSMapView!
    let floatingButton_back = MDCFloatingButton()
    let floatingButton_draw = MDCFloatingButton(shape: .mini)
    let floatingButton_ok = MDCFloatingButton(shape: .mini)
    let floatingButton_trash = MDCFloatingButton(shape: .mini)
    let floatingButton_delete = MDCFloatingButton(shape: .mini)
    let progressDialog:ProgressDialogView = ProgressDialogView()
    var locationManager = CLLocationManager()
    let realm = try! Realm()
    var str_latitude : String = ""
    var str_longitude : String = ""
    var rect = GMSMutablePath()
    var firstTuchCheck = 0 //구역설정시 처음 찍은 위치 구별하기 위한 변수
    var la:Double = 0.0
    var lon:Double = 0.0
    var draw_mode:Bool = false
    var realmCount :Int = 1
    let UUID = UIDevice.current.identifierForVendor?.uuidString
    let IP_ADDRESS = (Value.sharedInstance().IP_ADDRESS)

    var chek_assemble :Bool = false
    // 집결위치를 표시할 마커
    var AssembleMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    
    //지도에 추가할 폴리곤과 라인
    var Fpolyline = GMSPolyline(path: nil)
    var Fpolygon = GMSPolygon(path: nil)
    
    //처음 터치한 위치 저장
    var ex_la:Double = 0.0
    var ex_lon:Double = 0.0
    
    // 마커 링크 리스트(포인터) 사용
    var markerList = LinkedList<GMSMarker>(head: Node(value: GMSMarker(position: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)) , next: nil))
    var lineMarkerList = LinkedList<GMSMarker>(head: Node(value: GMSMarker(position: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)), next: nil))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //0,1 번째 노드는 삭제가 불가능 하기때문에 리스트의 헤드와 헤드.next 를 초기화 해준다.
        let marker2 = GMSMarker(position: CLLocationCoordinate2D(latitude:1.1, longitude: 1.1))
        let linemarker2 = GMSMarker(position: CLLocationCoordinate2D(latitude:1.1, longitude: 1.1))
        
        markerList.append(Node(value: marker2 , next: nil))
        lineMarkerList.append(Node(value: linemarker2, next: nil))
        
        

        // MARK: - 지도작동 부분 -----------------
        

        
        //if locationManager == nil {
            locationManager = CLLocationManager()
            // 델리게이트 설정
            locationManager.delegate = self
            // 거리 정확도 설정
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            // 업데이트 이벤트가 발생하기전 장치가 수평으로 이동해야 하는 최소 거리(미터 단위)
            locationManager.distanceFilter = 1
            // 앱이 suspend 상태일때 위치정보를 수신받는지에 대한 결정
            locationManager.allowsBackgroundLocationUpdates = true
            // location manager가 위치정보를 수신을 일시 중지 할수 있는지에 대한 결정
            locationManager.pausesLocationUpdatesAutomatically = false
            // 사용자에게 허용 받기 alert 띄우기
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
            // 아이폰 설정에서의 위치 서비스가 켜진 상태라면
            if CLLocationManager.locationServicesEnabled() {
                print("위치 서비스 On 상태")
                locationManager.startUpdatingLocation() //위치 정보 받아오기 시작
            } else {
                print("위치 서비스 Off 상태")
            }
        //}
        
        //지도 띄우기
        mapView = GMSMapView(frame: view.frame)
        mapView.delegate = self  // 델리게이트 설정은 프레임 설정 후 할것!!!

        self.view = mapView
    
        mapView.isMyLocationEnabled = true//내위치 따라다니게 하기(파란점)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        // 항상 위치정보를 사용한다는 판업이 발생
        //locationManager.requestWhenInUseAuthorization()

        locationManager.requestAlwaysAuthorization()
        
        locationManager.startUpdatingLocation()
        Task.init{
            //집결위치 가져오기
            await addPoly()
            await addFriendLocation()
        }
        
        rect.removeAllCoordinates()
        
        Task.init{

            //집결위치 가져오기
            await addPoly2()
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
                    
                    Fpolygon = GMSPolygon(path: rect)
                    Fpolygon.fillColor = UIColor(displayP3Red: 200/255, green: 0, blue: 0, alpha: 0.1)
                    Fpolygon.map = mapView
                    
                    floatingButton_draw.isHidden = true
                    floatingButton_ok.isHidden = true
                    floatingButton_trash.isHidden = false
                }
                else{ //완료버튼을 누르지 못했을 때 예외처리
                    //데이터 베이스에 저장되어있는 폴리라인 위치값 삭제
                    rect.removeAllCoordinates()
                        //서버측 폴리곤 지우기////
                        let request = NSMutableURLRequest(url: NSURL(string: "http://\(IP_ADDRESS)/deletepoly2.php")! as URL)
                        request.httpMethod = "POST"
                        let task = URLSession.shared.dataTask(with: request as URLRequest) {
                            data, response, error in

                            if error != nil {
                                print("error=\(String(describing: error))")
                                return
                            }
                        }
                        task.resume()

                }
            }
            else {
                //데이터 베이스에 저장되어있는 폴리라인 위치값 삭제
                rect.removeAllCoordinates()
                    //서버측 폴리곤 지우기////
                    let request = NSMutableURLRequest(url: NSURL(string: "http://\(IP_ADDRESS)/deletepoly2.php")! as URL)
                    request.httpMethod = "POST"
                    let task = URLSession.shared.dataTask(with: request as URLRequest) {
                        data, response, error in

                        if error != nil {
                            print("error=\(String(describing: error))")
                            return
                        }
                    }
                    task.resume()
            }
            //][][][][[]][[]][][][][][][][][][][][][][][][][][][][][][][]
        }
        
        move(at: locationManager.location?.coordinate)
        
        //튜토리얼 뷰 띄우기
        let savedTuto = realm.objects(Me.self)
        let fstTuto = savedTuto[0]
        
        if fstTuto.AdTutoN != "1" {
            showTuto()
        }
    
        
        //뒤로가기 버튼 생성
        func setFloatingButton_back() {
            //let bgColor :Color = Color(#colorLiteral(red: 0.730852209, green: 0.8209240846, blue: 0.7496752832, alpha: 1)) // 컬러 코드로 뽑기용
            let image = UIImage(systemName: "arrowshape.turn.up.backward.fill")
            floatingButton_back.sizeToFit()
            floatingButton_back.translatesAutoresizingMaskIntoConstraints = false
            floatingButton_back.setImage(image, for: .normal)
            floatingButton_back.setImageTintColor(.white, for: .normal)
            floatingButton_back.backgroundColor = UIColor(Color(#colorLiteral(red: 0.730852209, green: 0.8209240846, blue: 0.7496752832, alpha: 1)))
            floatingButton_back.addTarget(self, action: #selector(backtap), for: .touchUpInside)
            view.addSubview(floatingButton_back)
            view.addConstraint(NSLayoutConstraint(item: floatingButton_back, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 65))
            view.addConstraint(NSLayoutConstraint(item: floatingButton_back, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 15))

            }
        
        //그리기 버튼 생성
        func setFloatingButton_draw() {
            
            let image = UIImage(systemName: "hand.draw")
            floatingButton_draw.sizeToFit()
            floatingButton_draw.translatesAutoresizingMaskIntoConstraints = false
            floatingButton_draw.setImage(image, for: .normal)
            floatingButton_draw.setImageTintColor(.white, for: .normal)
            floatingButton_draw.backgroundColor = .darkGray
            floatingButton_draw.addTarget(self, action: #selector(drawtap), for: .touchUpInside)
            view.addSubview(floatingButton_draw)
            view.addConstraint(NSLayoutConstraint(item: floatingButton_draw, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 65))
            view.addConstraint(NSLayoutConstraint(item: floatingButton_draw, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: -25))

            }
        
        //완료 버튼 생성
        func setFloatingButton_ok() {

            let image = UIImage(systemName: "checkmark")
            floatingButton_ok.sizeToFit()
            floatingButton_ok.translatesAutoresizingMaskIntoConstraints = false
            floatingButton_ok.setImage(image, for: .normal)
            floatingButton_ok.setImageTintColor(.white, for: .normal)
            floatingButton_ok.backgroundColor = .blue
            floatingButton_ok.addTarget(self, action: #selector(oktap), for: .touchUpInside)
            view.addSubview(floatingButton_ok)
            view.addConstraint(NSLayoutConstraint(item: floatingButton_ok, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 65))
            view.addConstraint(NSLayoutConstraint(item: floatingButton_ok, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: -25))

            }
        
        //라인 지우기 버튼 생성
        func setFloatingButton_trash() {

            let image = UIImage(systemName: "trash")
            floatingButton_trash.sizeToFit()
            floatingButton_trash.translatesAutoresizingMaskIntoConstraints = false
            floatingButton_trash.setImage(image, for: .normal)
            floatingButton_trash.setImageTintColor(.white, for: .normal)
            floatingButton_trash.backgroundColor = .red
            floatingButton_trash.addTarget(self, action: #selector(trashtap), for: .touchUpInside)
            view.addSubview(floatingButton_trash)
            view.addConstraint(NSLayoutConstraint(item: floatingButton_trash, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 65))
            view.addConstraint(NSLayoutConstraint(item: floatingButton_trash, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: -25))

            }
        
        
        //삭제 버튼 생성
        func setFloatingButton_delete() {

            let image = UIImage(systemName: "flag.slash.fill")
            floatingButton_trash.sizeToFit()
            floatingButton_delete.translatesAutoresizingMaskIntoConstraints = false
            floatingButton_delete.setImage(image, for: .normal)
            floatingButton_delete.setImageTintColor(.white, for: .normal)
            floatingButton_delete.backgroundColor = .red
            floatingButton_delete.addTarget(self, action: #selector(deletetap), for: .touchUpInside)
            view.addSubview(floatingButton_delete)
            view.addConstraint(NSLayoutConstraint(item: floatingButton_delete, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -65))
            view.addConstraint(NSLayoutConstraint(item: floatingButton_delete, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: -25))

            }
        
        
        setFloatingButton_back()
        setFloatingButton_ok()
        setFloatingButton_draw()
        setFloatingButton_trash()
        setFloatingButton_delete()
      
        floatingButton_ok.isHidden = true
        floatingButton_trash.isHidden = true
        floatingButton_delete.isHidden = true
        
    }
    
    
    
    //뒤로가기 버튼 이벤트
    @objc func backtap(_ sender: Any) {
        dismiss(animated: true)
        //mTimer!.invalidate()
    }
    
    
    //그리기 버튼 이벤트
    @objc func drawtap(_ sender: Any) {
        floatingButton_draw.isHidden = true
        floatingButton_ok.isHidden = false
        draw_mode = true
        
    }
    //완료 버튼 이벤트
    @objc func oktap(_ sender: Any) {
        
        //1개, 2개일때는 생성 불가
        if lineMarkerList.size() >= 4
        {
            rect.addLatitude(la, longitude: lon)
            
            floatingButton_ok.isHidden = true
            floatingButton_trash.isHidden = false
            
            draw_mode = false
            
            Fpolyline.map = nil
            Fpolyline = GMSPolyline(path: rect)
            Fpolyline.strokeWidth = 3.0
            Fpolyline.strokeColor = .darkGray
            Fpolyline.geodesic = true
            Fpolyline.map = mapView
            
            Fpolygon = GMSPolygon(path: rect)
            Fpolygon.fillColor = UIColor(displayP3Red: 200/255, green: 0, blue: 0, alpha: 0.2)
            Fpolygon.map = mapView
            
            firstTuchCheck = 0
            
            //서버측으로 첫번째 찍은 보내기
            str_latitude = String(la)
            str_longitude = String(lon)
            let request = NSMutableURLRequest(url: NSURL(string: "http://\(IP_ADDRESS)/insertpoly2.php")! as URL)
            request.httpMethod = "POST"
            let postString = "str_latitude=\(str_latitude)&str_longitude=\(str_longitude)"
            request.httpBody = postString.data(using: String.Encoding.utf8)
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in

                if error != nil {
                    print("error=\(String(describing: error))")
                    return
                }
            }
            task.resume()
            showToast(message: "구역을 설정하였습니다!")
        }
        else
        {
            showToast(message: "핀을 3개이상 꽂아주세요!")
        }
    }
    //라인 삭제 버튼 이벤트
    @objc func trashtap(_ sender: Any) {
        floatingButton_trash.isHidden = true
        floatingButton_draw.isHidden = false
        
        //위치 데이터 삭제
        rect.removeAllCoordinates()
        
        //폴리곤 삭제
        Fpolygon.map = nil
        
        //라인 마커 삭제
        if lineMarkerList.size() > 1
        {
            let i:Int = 2
            while i <= lineMarkerList.size(){
                lineMarkerList.findNode(at: i)?.value.map = nil
                lineMarkerList.remove(at: i)
            }
        }
        Fpolyline.map = nil
        
        //서버측 폴리곤 지우기////
        let request = NSMutableURLRequest(url: NSURL(string: "http://\(IP_ADDRESS)/deletepoly2.php")! as URL)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in

            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
        }
        task.resume()
        
        showToast(message: "구역을 삭제하였습니다!!")
    }
    
    
    //삭제 버튼 이벤트
    @objc func deletetap(_ sender: Any) {

        //서버측 집합위치 지우기////
        let request = NSMutableURLRequest(url: NSURL(string: "http://\(IP_ADDRESS)/deletepoly.php")! as URL)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in

            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
        }
        task.resume()
        
        AssembleMarker.map = nil
        
        chek_assemble = false
        
        floatingButton_delete.isHidden = true
        ///-==-=--==-=-=-==--==-=-=-=-=-=-=-
        showToast(message: "집학위치를 삭제하였습니다!!")
    }

    //-=--==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-==-=-=-=--=-=-=-=-==-=--==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    // MARK: MAP 함수
    
    func move(at coordinate: CLLocationCoordinate2D?) {
        guard let coordinate = coordinate else {
            return
        }
        
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 14.0)
        mapView.camera = camera
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task.init{
            //서버로 받아온 친구들의 위치에 핀 꽂는 함수
            await addFriendLocation()
        }
        
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
                let position = CLLocationCoordinate2D(latitude: Double(item["str_latitude"]!)!, longitude: Double(item["str_longitude"]!)!)
                let Fmarker = GMSMarker(position: position)
                let fla: Double = position.latitude
                let flon: Double = position.longitude
                let Fposition = CLLocationCoordinate2D(latitude: fla, longitude: flon)
                if rect.count() != 0 && draw_mode == false{
                    if rect.contains(coordinate: Fposition, geodesic: false) {
                        Fmarker.title = item["name"]!
                        Fmarker.icon = UIImage(named: "studentpin.png")
                        Fmarker.map = mapView
                        //링크 리스트로 연결
                        markerList.append(Node(value: Fmarker, next: nil))
                    }else{
                            Fmarker.title = item["name"]!
                            Fmarker.icon = UIImage(named: "Outstudentpin.png")
                            Fmarker.map = mapView
                            //링크 리스트로 연결
                            markerList.append(Node(value: Fmarker, next: nil))
                    }
                }else{
                    Fmarker.title = item["name"]!
                    Fmarker.icon = UIImage(named: "studentpin.png")
                    Fmarker.map = mapView
                    //링크 리스트로 연결
                    markerList.append(Node(value: Fmarker, next: nil))
                }
          }
            
        }catch{
            //return "error"
        }
    }
    
    
    // 집합 위치를 추가해 주는 부분
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
                AssembleMarker.map = nil
                AssembleMarker = GMSMarker(position: position)
                AssembleMarker.title = "집합 위치"
                AssembleMarker.icon = UIImage(named: "assemblepin.png")
                AssembleMarker.snippet = ""
                AssembleMarker.map = mapView
                chek_assemble = true
                floatingButton_delete.isHidden = false
            }
        }catch{
            //return "error"
        }
    }
    
    func addPoly2() async{
        do{
            guard let url = URL(string: "http://\(IP_ADDRESS)/getMyPoly2.php") else { fatalError("Missing URL") }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            let friendLocations = json
            let friendLocation =  friendLocations["poly2"] as? [[String: String]]
            for item in friendLocation ?? [] {
                let position = CLLocationCoordinate2D(latitude: Double(item["str_latitude"]!)!, longitude: Double(item["str_longitude"]!)!)
                rect.addLatitude(position.latitude, longitude: position.longitude)
            }
        }catch{
            //return "error"
        }
    }
    
   
    //지도 터치 이벤트
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if draw_mode == true{
            
            Fpolyline.map = nil
            
           //처음 핀 위치 저장
           if firstTuchCheck == 0{
               la = coordinate.latitude
               lon = coordinate.longitude
               firstTuchCheck = 1
           }
            
           let marker = GMSMarker()
           
           marker.position = coordinate
           marker.title = "구역설정위치"
           marker.icon = UIImage(named: "areapin.png")
           marker.snippet = ""
           //marker.icon = GMSMarker.markerImage(with: UIColor.black)
           marker.map = mapView
            
            //링크 리스트로 연결
            lineMarkerList.append(Node(value: marker, next: nil))
           
           rect.addLatitude(coordinate.latitude, longitude: coordinate.longitude)

            Fpolyline = GMSPolyline(path: rect)
            Fpolyline.strokeWidth = 2.0
            Fpolyline.strokeColor = .darkGray
            Fpolyline.geodesic = true
            
            Fpolyline.map = mapView
            
            //서버측으로 좌표 보내기
            str_latitude = String(coordinate.latitude)
            str_longitude = String(coordinate.longitude)
            let request = NSMutableURLRequest(url: NSURL(string: "http://\(IP_ADDRESS)/insertpoly2.php")! as URL)
            request.httpMethod = "POST"
            let postString = "str_latitude=\(str_latitude)&str_longitude=\(str_longitude)"
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

    }

    
    //지도 길게 누르기 이벤트
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        
        floatingButton_delete.isHidden = false
        
        if(chek_assemble == true)
        {
            showToast(message: "이미 생성되었습니다.")
        }
        else if(chek_assemble == false)
        {
            AssembleMarker = GMSMarker()
            AssembleMarker.position = coordinate
            AssembleMarker.title = "집합위치"
            AssembleMarker.icon = UIImage(named: "assemblepin.png")
            AssembleMarker.map = mapView
            
            //서버측으로 좌표 보내기
            str_latitude = String(coordinate.latitude)
            str_longitude = String(coordinate.longitude)
            let request = NSMutableURLRequest(url: NSURL(string: "http://\(IP_ADDRESS)/insertpoly.php")! as URL)
            request.httpMethod = "POST"
            let postString = "str_latitude=\(str_latitude)&str_longitude=\(str_longitude)"
            request.httpBody = postString.data(using: String.Encoding.utf8)

            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in
                if error != nil {
                    print("error=\(String(describing: error))")
                    return
                }
            }
            task.resume()
            
            chek_assemble = true
            
            Task.init{
                await pushAssembleNoti()
            }
        }

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

    // 서버측에 uuid와 이름을 보내기
    func pushAssembleNoti(){
        //전체 알림 보내기
        let request = NSMutableURLRequest(url: NSURL(string: "http://\(IP_ADDRESS)/pushAssemble.php")! as URL)
        request.httpMethod = "POST"
        let postString = "UUID=\(String(describing: UUID!))"
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
    
    func showTuto() {
        let TTStoryboard = UIStoryboard.init(name : "Tutorial", bundle : nil)
        guard let TTView = TTStoryboard.instantiateViewController(identifier: "AdTMVC") as? AdTutoriralViewControler else {return}
        self.present(TTView, animated: true, completion: nil)
    }
    //-=—==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=—=-==-=-=-=—=-=-=-=-==-=—==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    
}
