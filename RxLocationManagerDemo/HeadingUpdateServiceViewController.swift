//
//  HeadingUpdateServiceViewController.swift
//  RxLocationManager
//
//  Created by Hao Yu on 16/7/13.
//  Copyright © 2016年 GFWGTH. All rights reserved.
//

import UIKit
import CoreLocation
import RxSwift
import RxLocationManager

class HeadingUpdateServiceViewController: UIViewController {

    @IBOutlet weak var magneticHeadingValueLbl: UILabel!
    
    @IBOutlet weak var trueHeadingValueLbl: UILabel!
    
    @IBOutlet weak var headingAccuracyValueLbl: UILabel!
    
    @IBOutlet weak var timestampValueLbl: UILabel!
    
    @IBOutlet weak var toggleHeadingUpdateBtn: UIButton!
    
    @IBOutlet weak var trueHeadingSwitch: UISwitch!
    
    private var disposeBag = DisposeBag()
    
    private var headingSubscription: Disposable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trueHeadingSwitch.rx_value
            .subscribeNext{
                RxLocationManager.HeadingUpdate.trueHeading($0)
            }
            .addDisposableTo(disposeBag)

        toggleHeadingUpdateBtn.rx_tap
            .subscribeNext{
                [unowned self]
                _ in
                if self.headingSubscription == nil {
                    self.toggleHeadingUpdateBtn.setTitle("Stop", forState: .Normal)
                    self.headingSubscription = RxLocationManager.HeadingUpdate.heading
                        .subscribeNext{
                            [unowned self]
                            heading in
                            self.magneticHeadingValueLbl.text = heading.magneticHeading.description
                            self.trueHeadingValueLbl.text = heading.trueHeading.description
                            self.headingAccuracyValueLbl.text = heading.headingAccuracy.description
                            self.timestampValueLbl.text = heading.timestamp.description
                    }
                }else{
                    self.toggleHeadingUpdateBtn.setTitle("Start", forState: .Normal)
                    self.magneticHeadingValueLbl.text = ""
                    self.trueHeadingValueLbl.text = ""
                    self.headingAccuracyValueLbl.text = ""
                    self.timestampValueLbl.text = ""
                    self.headingSubscription!.dispose()
                    self.headingSubscription = nil
                }
            }
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}