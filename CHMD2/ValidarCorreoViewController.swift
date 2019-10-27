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

extension OperatingSystemVersion {
    func getFullVersion(separator: String = ".") -> String {
        return "\(majorVersion)\(separator)\(minorVersion)\(separator)\(patchVersion)"
    }
}

class ValidarCorreoViewController: UIViewController {
    var email:String="jacozon@gmail.com"
    var so:String=""
    var deviceToken = ""
    
    @IBOutlet weak var lblMensaje: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
     }
    
    override func viewDidAppear(_ animated: Bool) {
        print(email)
        let address="https://www.chmd.edu.mx/WebAdminCirculares/ws/validarEmail.php?correo=\(email)"
        let _url = URL(string: address)!
        validarEmail(url: _url)
        
       
        
        
    }
    
    
    func validarEmail(url:URL){
        var valida:Int=0
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            if let datos = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [[String:Any]] {
                
                    let obj = datos[0] as! [String : AnyObject]
                    let existe = obj["existe"] as! String
                    valida = Int(existe) ?? 0
                
                
            }
            
            }.resume()
        print(valida)
        //if (valida==1){
        //TODO: Cuando pase a produccion
        if (valida==0 || valida==1){
             lblMensaje.text="Cuenta de correo validada"
            
            
            //Registrar dispositivo
            email = UserDefaults.standard.string(forKey: "email") ?? ""
            let os = ProcessInfo().operatingSystemVersion
            so = "iOS \(os.getFullVersion())"
            deviceToken = Messaging.messaging().fcmToken ?? ""
            
            registrarDispositivo(direccion: "https://www.chmd.edu.mx/pruebascd/app/webservices/registrarDispositivo.php", correo: email, device_id: deviceToken, so: so)
            
            
             performSegue(withIdentifier: "validarSegue", sender: self)
            
          
            
            
            
        }else{
            //Crear y presentar un cuadro de alerta cuando no se encuentre el email en la base
            let alert = UIAlertController(title: "CHMD", message: "No puedes acceder utilizando esta cuenta. Llama al administrador", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cerrar", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    
    func registrarDispositivo(direccion:String, correo:String, device_id:String, so:String){
        let parameters: Parameters = ["correo": correo, "device_token": device_id,"plataforma":so]      //This will be your parameter
        Alamofire.request(direccion, method: .post, parameters: parameters).responseJSON { response in
            switch (response.result) {
            case .success:
                print(response)
                break
            case .failure:
                print(Error.self)
            }
        }
    }
    

}
