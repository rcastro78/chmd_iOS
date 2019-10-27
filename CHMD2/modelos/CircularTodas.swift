//
//  CircularTodas.swift
//  CHMD2
//
//  Created by Rafael David Castro Luna on 7/23/19.
//  Copyright © 2019 Rafael David Castro Luna. All rights reserved.
//

import UIKit

class CircularTodas: NSObject {
    var nombre:String
    var encabezado:String
    var fecha:String
    var id:Int=0;
    var imagen:UIImage
    var estado:Int
    init(id:Int,imagen:UIImage,encabezado:String,nombre:String,fecha:String,estado:Int) {
        self.id=id
        self.nombre=nombre
        self.encabezado = encabezado
        self.fecha = fecha
        self.imagen = imagen
        self.estado = estado
    
    }
    
}
