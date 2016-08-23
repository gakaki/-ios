//
//  ModelSld.swift
//  sld
//
//  Created by g on 16/7/26.
//  Copyright © 2016年 g. All rights reserved.
//
import JSONCodable

struct VoSld {
    var id:String               = ""
    var name:String             = ""
    var parent_id:String        = ""
    var level_type:String       = ""
    var subCities               = [VoSld]()
    var subDistricts            = [VoSld]()
    
    mutating func setSubCities(inout s:[VoSld]){
        subCities = s
    }
    mutating func setSubDistricts(inout s:[VoSld]){
        subDistricts = s
    }
}

struct VoSldData {
    
    var slds: [VoSld]           = []
    var provinces:[VoSld]       = [] //省
    var cities:[VoSld]          = [] //市
    var districts:[VoSld]       = [] //区
    
    mutating func fliter_data(){

        for (index, item) in provinces.enumerate() {
            provinces[index].subCities = cities.filter{ (sld) in sld.parent_id == item.id }
        }
        for (index, item) in cities.enumerate() {
            cities[index].subDistricts = districts.filter{ (sld) in sld.parent_id == item.id }
        }
    }

}

extension VoSldData: JSONDecodable {
    
    func getProvinceFirst() -> VoSld {
        return provinces[0] //北京那个咯
    }
    
    func getSubCities( province:VoSld ) -> [VoSld]{
        let sub_cities = cities.filter { (c) -> Bool in
            c.parent_id == province.id
        }
        return sub_cities
    }
    
    func getSubDistricts(city:VoSld)-> [VoSld]{
        let sub_districts = districts.filter { (d) -> Bool in
            d.parent_id == city.id
        }
        return sub_districts
    }
    init(object: JSONObject) throws {
        let decoder     = JSONDecoder(object: object)
        slds            = try decoder.decode("RECORDS")
        
        provinces       = slds.filter{ (sld) in sld.level_type == "1" }
        cities          = slds.filter{ (sld) in sld.level_type == "2" }
        districts       = slds.filter{ (sld) in sld.level_type == "3" }
        
        fliter_data()
    }
}

extension VoSld: JSONDecodable {
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        
        id              = try decoder.decode("id")
        name            = try decoder.decode("name")
        parent_id       = try decoder.decode("parent_id")
        level_type      = try decoder.decode("level_type")
    }
}


