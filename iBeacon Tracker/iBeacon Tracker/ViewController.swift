//
//  ViewController.swift
//  iBeacon Tracker
//
//  Created by Joe Chen on 2019/4/23.
//  Copyright © 2019 Joe Chen. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import AudioToolbox

class ViewController: UIViewController, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate {

    
    @IBOutlet weak var closeDogImg: UIImageView!
    @IBOutlet weak var nearDogImg: UIImageView!
    @IBOutlet weak var farDogImg: UIImageView!
    @IBOutlet weak var dogImage: UIImageView!
    @IBOutlet weak var UUIDText: UITextField!
    @IBOutlet weak var loaring_paw: UIImageView!
    @IBOutlet weak var loadingDarkView: UIView!
    @IBOutlet weak var showInfoTableBtn: UIButton!
    var objectsViewController: iBeaconTableViewController?
    let locationManager = CLLocationManager()
    var UUIDStr = ""
    var beaconInfo = [UUIDRecord]()
    var petDisappearCount : Int = 0
    
    let moc = RecordContext.shared()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self){
            if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways{
                locationManager.requestAlwaysAuthorization()
            }
        }
//        UUIDText.text = "74278BDA-B644-4520-8F0C-720EAF059935"
//        UUIDText.text = "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"
        closeDogImg.isHidden = true
        nearDogImg.isHidden = true
        farDogImg.isHidden = true
        
        let darkViewClick = UITapGestureRecognizer.init(target: self, action: #selector(darkViewHidden))
        darkViewClick.numberOfTapsRequired = 1
        self.loadingDarkView.addGestureRecognizer(darkViewClick)
        
        promptiBeaconDetection(animate: false)
        
    }
    
    @objc func darkViewHidden(){
        self.loadingDarkView.isHidden = true
    }
    
    @IBAction func hahatouch(_ sender: Any) {
        
        closeDogImg.isHidden = true
        nearDogImg.isHidden = true
        farDogImg.isHidden = true
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        let alertCTL = UIAlertController(title: "寵物離你很遠囉！！", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "確定", style: .cancel) { (UIAlertAction) in
            
            self.petDisappearCount = 0
        }
        alertCTL.addAction(alertAction)
        self.present(alertCTL, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        findDBUUID()
    }

    @IBAction func UUIDEnter(_ sender: Any) {
        
        self.showAlertToEnterUUID()
        
    }
    
    func promptiBeaconDetection(animate : Bool){
        
        if(animate == true){
            self.loadingDarkView.isHidden = false
            self.loadingDarkView.backgroundColor = UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0.3)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat], animations: {
                
                self.loaring_paw.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.loaring_paw.transform = CGAffineTransform(scaleX: 4, y: 4)
                
            }) { (Bool) in
                
            }
        }else{
            
            self.loadingDarkView.isHidden = true
        }
    }
    
    func findDBUUID() -> Void {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UUIDRecord")
        request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: false)]
        do{
            self.beaconInfo = try moc.fetch(request) as! [UUIDRecord]
        }catch{
            fatalError("\(error)")
        }
        
        if(self.beaconInfo.count == 0){
            showAlertToEnterUUID()
        }
        
    }
    
    func calcDistByRSSI(rssi : Int) -> Double{
    
        let iRssi = abs(rssi)
        let power = Double(iRssi-60)/(10*2.0)
        print(pow(10, power))
        return pow(10, power)
    }
    
    func showAlertToEnterUUID() -> Void {
        
        let alertCTL = UIAlertController(title: "新增iBeacon", message: "請輸入UUID", preferredStyle: .alert)
        alertCTL.addTextField { (UITextField) in
            UITextField.placeholder = "iBeacon名稱"
            UITextField.keyboardType = UIKeyboardType.alphabet
        }
        alertCTL.addTextField { (UITextField) in
            UITextField.placeholder = "UUID"
            UITextField.keyboardType = UIKeyboardType.alphabet
        }
        let alertAction = UIAlertAction(title: "確定", style: .default) { (UIAlertAction) in
            
            guard let name = alertCTL.textFields?[0].text, let uuid = alertCTL.textFields?[1].text else{
                return
            }
            self.saveiBeaconToDB(name: name, uuid: uuid)
            self.registerBeaconRegionWithUUID(uuidString: uuid, identifier: "identifirer", isMonitor: true)
            
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertCTL.addAction(alertAction)
        alertCTL.addAction(cancelAction)
        self.present(alertCTL, animated: true)
    }
    
    func petExitTooFar(){
    
        if petDisappearCount == 5 {
            closeDogImg.isHidden = true
            nearDogImg.isHidden = true
            farDogImg.isHidden = true
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            let alertCTL = UIAlertController(title: "寵物離你很遠囉！！", message: "", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "確定", style: .cancel) { (UIAlertAction) in
    
                self.petDisappearCount = 0
            }
        alertCTL.addAction(alertAction)
        self.present(alertCTL, animated: true)
        }
    
    }
    
    
    func saveiBeaconToDB(name : String, uuid : String) -> Void{
        
        let entity = NSEntityDescription.entity(forEntityName:"UUIDRecord", in: moc)!
        let newUUID = NSManagedObject(entity: entity, insertInto: moc)
        
        let indexRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UUIDRecord")
        indexRequest.sortDescriptors = [NSSortDescriptor(key: "index", ascending: false)]
        let indexCount = try! self.moc.fetch(indexRequest) as! [UUIDRecord]
        
        if(indexCount.count == 0){
            newUUID.setValue(1, forKey: "index")
        }else{
            newUUID.setValue(indexCount[0].index + 1, forKey: "index")
        }
        
        newUUID.setValue(name, forKey: "name")
        newUUID.setValue(uuid, forKey: "uuid")
        
        do {
            try moc.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return
        }
    }

    
    func registerBeaconRegionWithUUID(uuidString: String, identifier: String, isMonitor: Bool){
        
        promptiBeaconDetection(animate: true)
        closeDogImg.isHidden = true
        nearDogImg.isHidden = true
        farDogImg.isHidden = true
        
        let region = CLBeaconRegion(proximityUUID: UUID(uuidString: uuidString)!, identifier: identifier)
        region.notifyOnEntry = true //預設就是true
        region.notifyOnExit = true //預設就是true
        
        if isMonitor{
            locationManager.startMonitoring(for: region) //建立region後，開始monitor region
        }else{
            locationManager.stopMonitoring(for: region)
            locationManager.stopRangingBeacons(in: region)

        }
        
    }
    
    
    
    //開始monitor region後，呼叫此delegate函數
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        //To check whether the user is already inside the boundary of a region
        //delivers the results to the location manager’s delegate "didDetermineState"
        manager.requestState(for: region)
    }
    
    //The location manager calls this method whenever there is a boundary transition for a region.
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == CLRegionState.inside{
            if CLLocationManager.isRangingAvailable(){
                manager.startRangingBeacons(in: (region as! CLBeaconRegion))
            }else{
                print("不支援ranging")
            }
        }else{
            manager.stopRangingBeacons(in: (region as! CLBeaconRegion))
        }
    }
    
    //The location manager calls this method whenever there is a boundary transition for a region.
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        if CLLocationManager.isRangingAvailable(){
            manager.startRangingBeacons(in: (region as! CLBeaconRegion))
        }else{
            print("不支援ranging")
        }
    }
    
    //The location manager calls this method whenever there is a boundary transition for a region.
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        manager.stopRangingBeacons(in: (region as! CLBeaconRegion))
        print("exit region")
        petExitTooFar()
//        view.backgroundColor = UIColor.white
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        if (beacons.count > 0){
            if let nearstBeacon = beacons.first{
                
                var proximity = ""
                
                switch nearstBeacon.proximity {
                case CLProximity.immediate:
                    proximity = "Very close"
                    
                case CLProximity.near:
                    proximity = "Near"
                    
                case CLProximity.far:
                    proximity = "Far"
                
                case CLProximity.unknown:
                    
                    proximity = "unknown"
                    
                default:
                    proximity = "default"
                }
                print(proximity)
                imageDistance(distance: proximity)
                
            }
        }
    }
    
    func imageDistance(distance : String){
        
        
        switch distance {
        case "Very close":
            closeDogImg.isHidden = false
            nearDogImg.isHidden = true
            farDogImg.isHidden = true
            promptiBeaconDetection(animate: false)
            self.petDisappearCount = 0
            
        case "Near":
            closeDogImg.isHidden = true
            nearDogImg.isHidden = false
            farDogImg.isHidden = true
            promptiBeaconDetection(animate: false)
            self.petDisappearCount = 0
            
        case "Far":
            
            closeDogImg.isHidden = true
            nearDogImg.isHidden = true
            farDogImg.isHidden = false
            promptiBeaconDetection(animate: false)
            self.petDisappearCount = 0
            
        case "unknown":
            
            self.petDisappearCount += 1
            petExitTooFar()
            
        default:
            print("default")
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error.localizedDescription)
    }
    
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print(error.localizedDescription)
    }

    @IBAction func showInfoTableView(_ sender: Any) {
        
        performSegue(withIdentifier: "showInfo", sender: showInfoTableBtn)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let popoverController = segue.destination.popoverPresentationController, let button = sender as? UIButton {
            popoverController.delegate = self
            popoverController.sourceView = button
            popoverController.sourceRect = button.bounds
        }
        
        let objectsViewController = segue.destination as! iBeaconTableViewController
        self.objectsViewController = objectsViewController
        objectsViewController.delegate = self
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}

extension ViewController: FetchTextDelegate {
    
    func fetchText(_ text: String) {
        
        
        self.registerBeaconRegionWithUUID(uuidString: text, identifier: "identifier", isMonitor: true)
        
    }
}
