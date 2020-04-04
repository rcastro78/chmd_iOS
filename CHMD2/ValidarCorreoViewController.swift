//
//  ValidarCorreoViewController.swift
//  CHMD2
//
//  Created by Rafael David Castro Luna on 8/9/19.
//  Copyright © 2019 Rafael David Castro Luna. All rights reserved.
//
import UIKit
import Alamofire
import Firebase
import Network
import GoogleSignIn
extension OperatingSystemVersion {
    func getFullVersion(separator: String = ".") -> String {
        return "\(majorVersion)\(separator)\(minorVersion)\(separator)\(patchVersion)"
    }
}

class ValidarCorreoViewController: UIViewController {
    var email:String=""
    var so:String=""
    var deviceToken = ""
    let v = UIView()
    @IBOutlet weak var lblMensaje: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        email = UserDefaults.standard.string(forKey: "email") ?? ""
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
                                         self.v.isHidden = true
                                     }
     }
    
   func finish(){
   var navigationArray = self.navigationController?.viewControllers //To get all UIViewController stack as Array
   navigationArray!.remove(at: (navigationArray?.count)! - 2) // To remove previous UIViewController
   self.navigationController?.viewControllers = navigationArray!
   }
    
    
    override func viewDidAppear(_ animated: Bool) {
        print(email)
                
        if(ConexionRed.isConnectedToNetwork()){
            let address="https://www.chmd.edu.mx/WebAdminCirculares/ws/validarEmail.php?correo=\(self.email)"
            let _url = URL(string: address)!
            validarEmail(url: _url)
        }else{
            var existe:String = UserDefaults.standard.string(forKey: "valida") ?? "0"
            let valida = Int(existe) ?? 0
            if(valida==1){
                performSegue(withIdentifier: "validarSegue", sender: self)
                finish()
               
                
            }else{
               
            }
                
           
            
        }
        
               
  
    }
        
     
    
    
    func validarEmail(url:URL){
        var valida:Int=0
        self.lblMensaje.text="Validando cuenta de correo"
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            if let datos = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [[String:Any]] {
                
                let obj = datos[0] as! [String : AnyObject]
                    let existe = obj["existe"] as! String
                    print("existe: "+existe)
                    valida = Int(existe) ?? 0
                    print("valida: \(valida)")
                    UserDefaults.standard.set(existe, forKey: "valida")
                
                
                if(valida==1){
                    
                    self.performSegue(withIdentifier: "validarSegue", sender: self)
                }else{
                    let dialogMessage = UIAlertController(title: "CHMD", message: "Esta cuenta de correo no está registrada en nuestra base de datos.", preferredStyle: .alert)
                                                    
                                                    // Create OK button with action handler
                                                    let ok = UIAlertAction(title: "Aceptar", style: .default, handler: { (action) -> Void in
                                                        //Forzar la eliminación de la cuenta utilizada
                                                       GIDSignIn.sharedInstance()?.signOut()
                                                       UserDefaults.standard.set("",forKey: "appleId")
                                                       UserDefaults.standard.set(0,forKey: "autenticado")
                                                       UserDefaults.standard.set(0,forKey: "cuentaValida")
                                                       UserDefaults.standard.set("", forKey: "nombre")
                                                       UserDefaults.standard.set("", forKey: "email")
                                                       //Retornar al login
                                                       self.performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
                                                       
                                                    })
                                                    
                                                    //Add OK and Cancel button to dialog message
                                                    dialogMessage.addAction(ok)
                                                  
                                                    
                                                    // Present dialog message to user
                                                    self.present(dialogMessage, animated: true, completion: nil)
                }
                
                
            }
            
            }.resume()
        print(valida)
        //if (valida==1){
        //TODO: Cuando pase a produccion
        if (valida==1){
           
            
        }else{
            //Crear y presentar un cuadro de alerta cuando no se encuentre el email en la base
          
        }
        
    }
    
    
    
    
    

}
