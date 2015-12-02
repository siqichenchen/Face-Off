
import Foundation
import XCPlayground

class asdfsad :NSObject{
    
    var timer: NSTimer!
    func a(){
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            print("test")
        }
    }
    func b(){
        timer = NSTimer.scheduledTimerWithTimeInterval(2,
            target: self,
            selector: Selector("ccc"),
            userInfo: nil,
            repeats: false)
    }
    func ccc(){
        print("c")
    }
}



//func delay(delay:Double, closure:()->()) {
//    dispatch_after(
//        dispatch_time(
//            DISPATCH_TIME_NOW,
//            Int64(delay * Double(NSEC_PER_SEC))
//        ),
//        dispatch_get_main_queue(), closure)
//}
//
//delay(2) {
//    print(222)
//}




class Test{
    init(){
        print("qq")
    }
}

let test = Test()
test
XCPSetExecutionShouldContinueIndefinitely()
