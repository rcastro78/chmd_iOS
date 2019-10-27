//
//  MenuPrincipal.swift
//  CHMD2
//
//  Created by Rafael David Castro Luna on 7/6/19.
//  Copyright © 2019 Rafael David Castro Luna. All rights reserved.
//

import UIKit

class MenuPrincipal: NSObject {
    var nombre:String
    var id:Int=0;
    var imagen:UIImage
    
    init(id:Int,nombre:String, imagen:UIImage) {
        self.id=id;
        self.nombre=nombre;
        self.imagen=imagen;
    }
}
