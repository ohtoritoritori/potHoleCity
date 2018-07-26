//
//  MapVC.swift
//  potHoleCity
//
//  Created by Victoria George on 10/9/17.
//  Copyright © 2017 Victoria George. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import MessageUI
import SpreadButton
import Lottie
import CallKit

class MapVC: UIViewController, UIGestureRecognizerDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, CXCallObserverDelegate {
    
    
    @IBOutlet weak var topLabel: UILabel!
    //map outlet
    @IBOutlet weak var mapView: MKMapView!
    
    //EmergencyView
    @IBOutlet weak var bottomBlueView: UIView!
    @IBOutlet weak var emergencyView: roundedShadowView!
    @IBOutlet weak var saveBtnOutlet: UIButton!
    @IBOutlet weak var nameTextFieldOutlet: UITextField!
    @IBOutlet weak var numberTextOutlet: UITextField!
    @IBOutlet weak var emailTextFieldOutlet: UITextField!
    @IBOutlet weak var nameStar: UILabel!
    @IBOutlet weak var numStar: UILabel!
    @IBOutlet weak var emailStar: UILabel!
    @IBOutlet weak var labelError: UILabel!
    @IBOutlet weak var errorNumber: UILabel!
    @IBOutlet weak var errorEmail: UILabel!
    @IBOutlet weak var emergencyContactLargeName: UILabel!
    
    // AppDelegate
    var callObserver: CXCallObserver!
    
    //Saving
    var defaults = UserDefaults.standard
    
    //Keys
    var userNameKeyConstant1: String?
    var userNumKeyConstant1: String?
    var userEmailKeyConstant1: String?
    
    var nameSaved = String()
    var numSaved = String()
    var emailSaved = String()
    
    var onOff1 = false
    var onOff2 = false
    var onOff3 = false
 
    //map variables
    var locationManager = CLLocationManager()
    let authorizationSatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    var long4Email = Double()
    var lat4Email = Double()
    
    
    var locationConverted = String()
    var streetConverted = String()
    var cityConverted = String()
    var zipCodeConverted = String()
    var countryConverted = String()
    
    var firstBtn = UIButton()
    
    //spreadbutton
    var spreadButton: SpreadButton!
    
    var callNow = false

    override func viewDidLoad() {
        super.viewDidLoad()
        defaults = UserDefaults.standard
        print("inside view did load")
       
        //phone call checker
        callObserver = CXCallObserver()
        callObserver.setDelegate(self, queue: nil)
        
        //map
        mapView.delegate = self
        locationManager.delegate = self
        
        configureLocationServices()
        addDoubleTap()
        
        //spreadbutton
        runWithSwiftCode();
        
        UITextField.appearance().tintColor = .white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        defaults = UserDefaults.standard
        
        let name1 = defaults.object(forKey: "userNameKeyConstant1")
        if name1 != nil {
            nameTextFieldOutlet.text = "\(name1 ?? "Enter Name")"
            emergencyContactLargeName.text = "\(name1 ?? "Emergency Contact")"
            nameSaved = name1 as! String
        }
        
        let num1 = defaults.object(forKey: "userNumKeyConstant1")
        if num1 != nil {
            numberTextOutlet.text = "\(num1 ?? "Enter Name")"
            numSaved = num1 as! String
        }
        let email1 = defaults.object(forKey: "userEmailKeyConstant1")
        if email1 != nil {
            emailTextFieldOutlet.text = "\(email1 ?? "Enter Name")"
            emailSaved = email1 as! String
        }

        
        
    }
    
    //map funcs
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }

    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authorizationSatus == .authorizedAlways || authorizationSatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        
        if self.locationConverted.contains(self.cityConverted) {
            
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients(["customerrelations@flower-mound.com"])
            mailComposerVC.setCcRecipients(["kfmb@kmfb.org, \(String(describing: self.emailSaved))"])
            mailComposerVC.setBccRecipients(["tori@thecoderschool.com"])
            mailComposerVC.setSubject("There is an issue in Flower Mound!")
            mailComposerVC.setMessageBody("There is an issue at my location: \n Longitude: \(self.long4Email)\n Latitude: \(self.lat4Email)\n\n\n\n\n\n This is an automated message from Pothole App \n", isHTML: false)
            return mailComposerVC
            
        } else {
        
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["customerrelations@flower-mound.com"])
        mailComposerVC.setCcRecipients(["kfmb@kmfb.org", "\(String(describing: self.emailSaved))"])
        mailComposerVC.setBccRecipients(["tori@thecoderschool.com"])
        mailComposerVC.setSubject("There is an issue in Flower Mound!")
        mailComposerVC.setMessageBody("There is an issue at my location: \n \(self.locationConverted)\n\(self.cityConverted)\n\(self.zipCodeConverted)\n\n\n\n\n\n This is an automated message from Pothole App \n", isHTML: false)
        return mailComposerVC
            
        }
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send ", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
        
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        print("Got inside cancel mail function")
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }


    
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded == true {
            print("Disconnected")
 
            if(UserDefaults.standard.object(forKey: "userNumKeyConstant1") == nil) {
                print("inside numberSaved == nil")
                let alertLocationError = UIAlertView(title: "No Emergency Contact Number.", message: "Pothole Cannot Send a Text if You Haven't Added an Emergency Contact.", delegate: self, cancelButtonTitle: "OK")
                alertLocationError.show()
                
            } else {
            
                if (MFMessageComposeViewController.canSendText()) {
                    
                    print("inside callobs cansendtext func")
                    if self.lat4Email != 0.0 && self.long4Email != 0.0 {
                        print("inside lat4Email != 0.0 && self.long4Email")
                        if self.locationConverted.contains(self.cityConverted) {
                            print("self.locationConverted.contains")
                            let controller = MFMessageComposeViewController()
                            controller.body = "There is an issue at my location: \n Longitude: \(self.long4Email)\n Latitude: \(self.lat4Email)\n\n\n\n\n\nThis is an automated message from Pothole App \n"
                            controller.recipients = ["\(String(describing: self.numSaved))"]
                            controller.messageComposeDelegate = self
                            self.present(controller, animated: true, completion: nil)

                            
                        } else {
                            print("self.locationConverted.contains ELSE")
                            let controller = MFMessageComposeViewController()
                            controller.body = "There is an issue at my location: \n \(self.locationConverted)\n\(self.cityConverted)\n\(self.zipCodeConverted)\n\n\n\n\n\n This is an automated message from Pothole App"
                            controller.recipients = ["\(String(describing: self.numSaved))"]
                            controller.messageComposeDelegate = self
                            self.present(controller, animated: true, completion: nil)

                        }
                    
                } else {
                        print("inside lat4Email != 0.0 && self.long4Email ELSE")
                    
                    let alertLocationError = UIAlertView(title: "Please Double Tap The Map To Drop a Pin on the Location of the Issue.", message: "Pothole Cannot Send a Text if You Haven't Dropped a Pin On The Map.", delegate: self, cancelButtonTitle: "OK")
                    alertLocationError.show()
                }
                
            } else {
                print("inside MFMessageComposeViewController.canSendText ELSE")
                let sendMessageErrorAlert = UIAlertView(title: "Could Not Send Text", message: "Your device could not send text.  Please check your texting configuration and try again.", delegate: self, cancelButtonTitle: "OK")
                sendMessageErrorAlert.show()
            }
          }
        }
    }
    
    //Saving Emergency Info
    
    @IBAction func nameTFAction(_ sender: Any) {
        saveName()
        saveNumber()
        saveEmail()
    }
    
    @IBAction func numberTFAction(_ sender: Any) {
        saveName()
        saveNumber()
        saveEmail()
    }
    
    @IBAction func emailTFAction(_ sender: Any) {
        saveName()
        saveNumber()
        saveEmail()
    }
    
    @IBAction func saveEditAction(_ sender: Any) {
        saveEmail()
        saveNumber()
        saveName()
        
        if onOff1 && onOff2 && onOff3 == true {
            saveBtnOutlet.setTitle("Saved!", for: UIControlState.normal)
        }
        emergencyView.isHidden = true
        bottomBlueView.isHidden = true
        self.spreadButton.isHidden = false
        
    }
    
    func saveName(){
        let name = nameTextFieldOutlet.text
        if (name?.contains(" "))! {
            userNameKeyConstant1  = String(describing: nameTextFieldOutlet.text!)
            defaults.set(userNameKeyConstant1, forKey: "userNameKeyConstant1")
            if userNameKeyConstant1 != nil {
                nameTextFieldOutlet.text = "\(String(describing: userNameKeyConstant1!))"
                emergencyContactLargeName.text = "\(String(describing: userNameKeyConstant1!))"
            }
            nameStar.isHidden = true
            labelError.isHidden = true
            onOff1 = true
        } else {
            print("name label should be showing now")
            nameStar.isHidden = false
            labelError.isHidden = false
            labelError.text = "Please put your first and last name."
        }
    }
    
    func saveNumber(){
        let number = String(describing: numberTextOutlet.text!)
        let numberLen = number.count
        
        if ((number.contains("-") || (number.contains("."))) || ((numberLen != 10))) {
            numStar.isHidden = false
            errorNumber.isHidden = false
            onOff1 = false
            errorNumber.text = "Please provide a number: XXXXXXXXXX"
        } else {
            numStar.isHidden = true
            errorNumber.isHidden = true
            onOff2 = true
            userNumKeyConstant1 = String(describing: numberTextOutlet.text!)
            defaults.set(userNumKeyConstant1, forKey: "userNumKeyConstant1")
        }
    }
    
    func saveEmail(){
        let Email = String(describing: emailTextFieldOutlet.text!)
        
        if (Email.contains("@") && (Email.contains("."))){
            
            emailStar.isHidden = true
            errorEmail.isHidden = true
            onOff3 = true
            print("Inside email if statement \(Email)")
            userEmailKeyConstant1 = String(describing: emailTextFieldOutlet.text!)
            defaults.set(userEmailKeyConstant1, forKey: "userEmailKeyConstant1")

        } else {
            print("Inside email else statement \(Email)")
            userEmailKeyConstant1 = " "
            emailStar.isHidden = false
            errorEmail.isHidden  = false
            errorEmail.text = "Please enter a valid email address."
        }
    }
    
    func runWithSwiftCode() {
        
        
        let sosButton = SpreadSubButton(backgroundImage: UIImage(named: "ambulance"), highlightImage: UIImage(named: "ambulance")) { (index, sender) -> Void in
            print("sos Pressed. This is emergency contacts number: \(String(describing: self.userNumKeyConstant1))")
            
            //This is my number. We will be changing it to 911 when released. 
            if let url = NSURL(string: "tel://\(8172280471)"), UIApplication.shared.canOpenURL(url as URL) {
                UIApplication.shared.openURL(url as URL)
            }
        }
        
        //spread buttonfuncs


        let Email = SpreadSubButton(backgroundImage: UIImage(named: "email"), highlightImage: UIImage(named: "email")) { (index, sender) -> Void in
            print("Email Pressed")
            let mailComposeViewController = self.configuredMailComposeViewController()
            
            if MFMailComposeViewController.canSendMail() {
                print("What The Heck Is Going On In: Lat: \(self.lat4Email) Long \(self.long4Email)")
                if self.lat4Email == 0.0 && self.long4Email == 0.0 {
                    print("Inside if statement 0.0")
                    let alertLocationError = UIAlertView(title: "Please Double Tap The Map To Drop a Pin.", message: "Pothole Cannot Send Email if You Haven't Dropped a Pin On The Map.", delegate: self, cancelButtonTitle: "OK")
                    alertLocationError.show()
                } else {
                    self.present(mailComposeViewController, animated: true, completion: nil)
                }
            } else {
                self.showSendMailErrorAlert()
            }
        }

   
        let settingsButton = SpreadSubButton(backgroundImage: UIImage(named: "contact"), highlightImage: UIImage(named: "contact")) { (index, sender) -> Void in
            print("fifth")
     
            self.emergencyView.isHidden = false
            self.bottomBlueView.isHidden = false
            self.spreadButton.isHidden = true
  
    }
        
        
        var firstButton = SpreadButton(image: UIImage(named: "unicornPowerz"),
                                        highlightImage: UIImage(named: "unicornPowerz"),
                                        position: CGPoint(x: 40, y: UIScreen.main.bounds.height - 40))
        self.spreadButton = firstButton
        
        
        spreadButton?.setSubButtons([sosButton,Email,settingsButton])
        spreadButton?.mode = SpreadMode.spreadModeSickleSpread
        spreadButton?.direction = SpreadDirection.spreadDirectionRightUp
        spreadButton?.radius = 90
        spreadButton?.positionMode = SpreadPositionMode.spreadPositionModeFixed
        //spreadButton?.buttonDidSpreadBlock = { _ in self.topLabel.text = ""}
        spreadButton?.buttonDidCloseBlock = { _ in self.topLabel.text = "Double tap to drop a pin on the issue"}
        if spreadButton != nil {
            self.view.addSubview(spreadButton!)
            
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
}


//map extensions

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.6104438305, green: 0.1513607502, blue: 0.6915461421, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()
        spreadButton.spreadButton()
        spreadButton.spreadSubButton()
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
       // topLabel.text = "Press the + for more options"
        mapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)

            // Add below code to get address for touch coordinates.
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                
                self.long4Email = touchCoordinate.longitude
                self.lat4Email = touchCoordinate.latitude
                
                

                // Place details
                var placeMark: CLPlacemark!
                placeMark = placemarks?[0]

                // Address dictionary
                print(placeMark.addressDictionary as Any)

                // Location name
                if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                    self.locationConverted = locationName as String
                    print("Hello here \(self.locationConverted)")
                }
                // Street address
                if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                    self.streetConverted = street as String
                    print(street)
                }
                // City
                if let city = placeMark.addressDictionary!["City"] as? NSString {
                    self.cityConverted = city as String
                    
                    print(city)
                }
                // Zip code
                if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                    self.zipCodeConverted = zip as String
                    print(zip)
                }
                // Country
                if let country = placeMark.addressDictionary!["Country"] as? NSString {
                    self.countryConverted = country as String
                    print(country)
                }
            })
        }

    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
}

extension MapVC: CLLocationManagerDelegate {
    
    func configureLocationServices(){
        if authorizationSatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }else{
            return
        }
    }
    //This func is for if the authorization has changed or wasn't loaded
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        centerMapOnUserLocation()
    }
}


