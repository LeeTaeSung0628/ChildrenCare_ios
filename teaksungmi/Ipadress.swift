
import Foundation


class Value {
    // * 싱글톤 객체를 이용하여 접근할 전역 변수 선언
    //   - 여기서는 String 타입의 전역 변수를 생성했다.
    public var IP_ADDRESS:String = "121.133.172.147:9327"
    
    
    // * 싱글톤 객체를 반환하는 함수를 구성한다.
    struct StaticInstance {
        static var instance: Value?
    }
    
    class func sharedInstance() -> Value {
        if (StaticInstance.instance == nil) {
            StaticInstance.instance = Value()
        }
        return StaticInstance.instance!
    }
}

