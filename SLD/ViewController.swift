//
//  ViewController.swift
//  sld
//
//  Created by g on 16/7/26.
//  Copyright © 2016年 g. All rights reserved.
//

import UIKit
import JSONCodable
import ObjectMapper
import SwiftyJSON
public func MGRgb(r:CGFloat,g:CGFloat,b:CGFloat,alpha:CGFloat = 1) -> UIColor{
    return UIColor(red:r/255.0, green: g/255.0, blue: b/255.0, alpha:alpha)
}
let GrayColorlevel2 = MGRgb(60, g: 60, b: 60)
let GrayColorLevel5 = MGRgb(245, g: 245, b: 245)
let MGScreenWidth:CGFloat = UIScreen.mainScreen().bounds.size.width
let MGScreenHeight:CGFloat = UIScreen.mainScreen().bounds.size.height


class ViewController: UIViewController {

    //MARK:Private vars
    lazy var pickerView                     = UIPickerView()

    // properties
    var data:VoSldData                      = VoSldData()
    var dataOM:[VoSldOM]?
    var voSldDataOm:VoSldDataOM             = VoSldDataOM()
    
    //选择的省索引
    var provinceIndex = 0
    //选择的市索引
    var cityIndex = 0
    //选择的县索引
    var districtIndex = 0
    
    @IBOutlet weak var txt_field: UITextField!
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let stopwatch = Stopwatch()
        
//        loadJson()
        self.voSldDataOm = CityDataManager.data
 
        print("elapsed time: \(stopwatch.elapsedTimeString())")
//
//        
//        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
//        let fileURL      = documentsURL.URLByAppendingPathComponent("city.plist")
//        
//        var fileManager  = NSFileManager.defaultManager()
//        let dict         = NSMutableDictionary()
//        dict.setValue(voSldDataOm, forKey: "data")
//        
//        var bundle : NSString = NSBundle.mainBundle().pathForResource("data", ofType: "plist")
//        fileManager.copyItemAtPath(bundle, toPath: path, error:nil)
//        data.setObject(object, forKey: "object")
//        data.writeToFile(path, atomically: true)
//        
//        if (!(fileManager.fileExistsAtPath(<#T##path: String##String#>)(path)))
//        {
//                    }
//
//        
//        
// 
//        
//        
        configPicker()
    }
    override func viewDidAppear(animated: Bool) {}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
  
    func loadJsonObjectMapper(){
        if let path = NSBundle.mainBundle().pathForResource("city", ofType: "json") {
            
            do {
                let json_str    = try! String(contentsOfURL: NSURL(fileURLWithPath: path), encoding: NSUTF8StringEncoding)
                if let dataFromString = json_str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    let json = JSON(data: dataFromString)
                    let a           = json["RECORDS"].arrayObject
                    dataOM          = try! Mapper<VoSldOM>().mapArray(a)
                }

            } catch let error as NSError {
                print(error.localizedDescription)
            }catch {
                print("error")
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    func loadJson(){
        if let path = NSBundle.mainBundle().pathForResource("city", ofType: "json") {
            
            do {
                let json_str    = try! String(contentsOfURL: NSURL(fileURLWithPath: path), encoding: NSUTF8StringEncoding)
                data = try! VoSldData(JSONString:json_str)
            } catch let error as NSError {
                print(error.localizedDescription)
            }catch {
                print("error")
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    func configPicker(){
        let view = UIView(frame:CGRectMake(0, 0, MGScreenWidth, 290))
        view.backgroundColor = UIColor.whiteColor()
        let topView = UIView(frame:CGRectMake(0, 0, MGScreenWidth, 40))
        topView.backgroundColor = UIColor.whiteColor()
        view.addSubview(topView)
        
        let cancelButton = UIButton(type: .System)
        cancelButton.backgroundColor = UIColor.whiteColor()
        cancelButton.setTitleColor(GrayColorlevel2, forState:.Normal)
        cancelButton.setTitle("取消", forState:.Normal)
        cancelButton.frame = CGRectMake(8, 0, 60, 40)
        cancelButton.addTarget(self, action:#selector(cancel), forControlEvents:.TouchUpInside)
        topView.addSubview(cancelButton)
        
        let sureButton = UIButton(type: .System)
        sureButton.setTitle("确定", forState:.Normal)
        sureButton.backgroundColor = UIColor.whiteColor()
        sureButton.setTitleColor(GrayColorlevel2, forState:.Normal)
        sureButton.frame = CGRectMake(MGScreenWidth - 68, 0, 60, 45)
        sureButton.addTarget(self, action:#selector(sure), forControlEvents:.TouchUpInside)
        topView.addSubview(sureButton)
        
        pickerView.frame = CGRectMake(0, 40, MGScreenWidth, 250)
        pickerView.backgroundColor      = GrayColorLevel5
        pickerView.delegate             = self
        pickerView.dataSource           = self
        view.addSubview(pickerView)
        txt_field.inputView = view

    }
    
    func cancel(){
        print("cancel")
        txt_field.resignFirstResponder()
    }
    
    func choosed_data_alert( province_index:Int, city_index:Int,district_index:Int ){
        
        txt_field.resignFirstResponder()
        
        //获取选中的省
        let province    = self.voSldDataOm.provinces[province_index]
        
        //获取选中的市
        let cities      = province.subCities!
        if ( cities.count <= 0) { //没有找到城市的问题其实还是需要从源头json上处理的
            //消息显示
            let alertController = UIAlertController(title: "出错没有找到城市",
                                                    message: "出错没有找到城市", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        let city        = cities[city_index]
        
        //获取选中的县（地区）
        let districts   = city.subDistricts!
        let district    = districts[district_index]
        
        
        //拼接输出消息
        let message = "索引：\(province_index)-\(city_index)-\(district_index)\n"
            + "值：\(province.name) - \(city.name) - \(district.name)"
        
        //消息显示
        let alertController = UIAlertController(title: "您选择了",
                                                message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "确定", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)

    }
    func sure() {
        
        let provinceIndex   = pickerView.selectedRowInComponent(0)
        let cityIndex       = pickerView.selectedRowInComponent(1)
        let districtIndex   = pickerView.selectedRowInComponent(2)

        choosed_data_alert(provinceIndex,city_index: cityIndex,district_index: districtIndex)
    }
    
    @IBAction func btnClick(sender: AnyObject) {
        
        choosed_data_alert(provinceIndex,city_index: cityIndex,district_index: districtIndex)
    }
}


extension ViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        

        switch (component) {
        case 0:
            return self.voSldDataOm.provinces.count
        case 1:
            let province    = self.voSldDataOm.provinces[provinceIndex]
            let cities      = province.subCities!
            return cities.count
        case 2:
            
            let province    = self.voSldDataOm.provinces[provinceIndex]
            let cities      = province.subCities!
            if ( cities.count <= 0 ){
                return 0
            }
            let  city       = cities[cityIndex]
            let districts   = city.subDistricts!
            return districts.count
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch (component) {
        case 0:
            let province    = self.voSldDataOm.provinces[row]
            return province.name
        case 1:
            let province    = self.voSldDataOm.provinces[provinceIndex]
            let cities      = province.subCities!
            let city        = cities[row]
            return city.name
        case 2:
            let province    = self.voSldDataOm.provinces[provinceIndex]
            let cities      = province.subCities!
            let city        = cities[cityIndex]
            let districts   = city.subDistricts!
            if ( districts.count > 0) {
                let district    = districts[row]
                return district.name
            }else{
                return ""
            }
        default:
            return ""
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        //根据列、行索引判断需要改变数据的区域
        
        switch (component) {
        case 0:
            
            provinceIndex = row;
            cityIndex = 0;
            districtIndex = 0;
            pickerView.reloadComponent(1);
            pickerView.selectRow(0, inComponent: 1, animated: false);

            // reselect 1st area

            pickerView.reloadComponent(2);
            pickerView.selectRow(0, inComponent: 2, animated: false);

        case 1:
            
            cityIndex           = row;
            districtIndex      = 0;
            
            // reselect 1st area
            pickerView.reloadComponent(2);
            pickerView.selectRow(0, inComponent: 2, animated: false);
            
        case 2:
            districtIndex      = row;
        default:
            break
        }
    
    }
} 

