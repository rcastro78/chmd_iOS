//
//  ViewController.swift
//  CHMD2
//
//  Created by Rafael David Castro Luna on 7/6/19.
//  Copyright © 2019 Rafael David Castro Luna. All rights reserved.
//
import UIKit
import AVKit
import AVFoundation
import GoogleSignIn
import SQLite3

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}


class ViewController: UIViewController,GIDSignInUIDelegate,GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error {
            print(error)
        }
        else {
           performSegue(withIdentifier: "verificarSegue", sender: self)
        }
    }
    
    var avPlayer:AVPlayer!
    var avPlayerLayer:AVPlayerLayer!
    var paused:Bool = false
    var db: OpaquePointer?
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
         if ConexionRed.isConnectedToNetwork() == true {
             GIDSignIn.sharedInstance().uiDelegate = self
         }else{
            let cuentaValida:Int = UserDefaults.standard.integer(forKey: "valida") ?? 0
            if(cuentaValida==1){
                print("Valida")
                self.performSegue(withIdentifier: "validarSinInternetSegue", sender: self)
            }else{
                
            }
        }
        
       
        
        
        
        
        let urlVideo = Bundle.main.url(forResource: "video_app", withExtension: "mp4")
        
        avPlayer = AVPlayer(url: urlVideo!)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        
        avPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = UIColor.clear;
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        /*NotificationCenter.default.addObserver(self,
                                               selector: Selector("playerItemDidReachEnd:"),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)*/
        
        //Crear el archivo para la base de datos cuando
        //no haya conexión a internet
        
        //Sección para la base de datos
        let fileUrl = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("chmd.sqlite")
        
        if(sqlite3_open(fileUrl.path, &db) != SQLITE_OK){
            print("Error en la base de datos")
        }
        
        let crearTablaCirculares = "CREATE TABLE IF NOT EXISTS appCircular(idCircular INTEGER, idUsuario INTEGER, nombre TEXT, textoCircular TEXT, no_leida INTEGER, leida INTEGER, favorita INTEGER, compartida INTEGER, eliminada INTEGER, created_at TEXT, updated_at TEXT)"
        if sqlite3_exec(db, crearTablaCirculares, nil, nil, nil) != SQLITE_OK {
            print("Error creando la tabla de las circulares")
        }
        
        
        
        
       
    }
    
    
    @IBAction func googleSignIn(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!){
        if (error != nil){
            let nombre:String = user.profile.givenName
            let email:String = user.profile.email
            
            print(nombre)
            print(email)
            UserDefaults.standard.set(1,forKey: "autenticado")
            UserDefaults.standard.set(nombre, forKey: "nombre")
            UserDefaults.standard.set(email, forKey: "email")
            
        }
    }
    
    
    func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: CMTime.zero)
    }
    
    
    //Esta función es para el redirect automático
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        avPlayer.play()
        paused = false
        
        let cuentaValida:Int = UserDefaults.standard.integer(forKey: "cuentaValida") ?? 0
        if(cuentaValida==1){
            print("Valida")
            performSegue(withIdentifier: "inicioSegue", sender: self)
        }else{
            print("Cuenta No Valida")
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        avPlayer.pause()
        paused = true
}
    
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        
    }

}
