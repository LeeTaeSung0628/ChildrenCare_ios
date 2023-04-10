//
//  TutoriralViewControler.swift
//  teaksungmi
//
//  Created by LTS on 2022/05/19.
//

import SwiftUI
import ImageSlideshow
import RealmSwift

class TutoriralViewControler: UIViewController {
  
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    @IBOutlet var slideshow: ImageSlideshow!
    
    let localSource = [BundleImageSource(imageString: "11"), BundleImageSource(imageString: "22"), BundleImageSource(imageString: "33"), BundleImageSource(imageString: "44")
                       , BundleImageSource(imageString: "55"), BundleImageSource(imageString: "66"), BundleImageSource(imageString: "77"), BundleImageSource(imageString: "88"), BundleImageSource(imageString: "99")]


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
            fstTuto.MTutoN = "1"
        }
        print(savedTuto[0].MTutoN)
    }

}

extension TutoriralViewControler: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}
