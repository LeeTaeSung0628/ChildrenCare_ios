//
//  TutoriralViewControler.swift
//  teaksungmi
//
//  Created by LTS on 2022/05/19.
//

import SwiftUI
import ImageSlideshow
import RealmSwift

class AdTutoriralViewControler: UIViewController {
  
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    
    @IBOutlet var slideshow: ImageSlideshow!
    
    let localSource = [BundleImageSource(imageString: "g11"), BundleImageSource(imageString: "g22"), BundleImageSource(imageString: "g33"), BundleImageSource(imageString: "g44")
                       , BundleImageSource(imageString: "g55")]


    override func viewDidLoad() {
        super.viewDidLoad()


        //slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideshow.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .customBottom(padding: 13))
        
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill

        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.delegate = self

        slideshow.setImageInputs(localSource)
        
        
        let savedTuto = realm.objects(Me.self)
        let fstTuto = savedTuto[0]
        
        // Realm 에 저장하기
        try! realm.write {
            fstTuto.AdTutoN = "1"
        }
        print(savedTuto[0].AdTutoN)
    }

}

extension AdTutoriralViewControler: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}
