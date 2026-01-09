//
//  Constant.swift
//  JustToysWorldApp
//
//  Created by Satyam on 24/11/25.
//

import Foundation
import UIKit
import AVFoundation
public typealias EIArray = [Any]
public typealias EIDictonary = [String:Any]
public typealias EIDictonaryToDictionary = [String:[String:Any]]
public typealias EIDictonaryArray = [[String:Any]]
public typealias successHandler = (Any?) -> Void
public typealias successHandlers = (Any?) -> Void
public typealias failureHandler = (Error?, String) -> Void

let kMainButtonRadius = IS_IPAD ? 35.0 : 23.0
let kSmallButtonRadius = IS_IPAD ? 23.0 : 18.0
let userdef = UserDefaults.standard
let IS_IPHONE = (UI_USER_INTERFACE_IDIOM() == .phone)



let IS_IPAD = (UI_USER_INTERFACE_IDIOM() == .pad)
let iosVersion = (UIDevice.current.systemVersion as NSString).floatValue
enum DeviceTypeModel{
    case iPhone12_mini_12_Pro
    case iPhones_6Plus_6sPlus_7Plus_8Plus
    case iPhoneXR_11
    case iPhones_6_6s_7_8
    case iphoneSE //SE is the like iphone 5 and iphone 5s
    case iphone4s
    case Unknown
}
struct ScreenSize
{
    static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS =  UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
}
func runOnTheDeviceType(_ completion: (DeviceTypeModel) -> Void) {
    if UIDevice().userInterfaceIdiom == .phone{
        switch UIScreen.main.nativeBounds.height{
        case 2436,2532:
            completion(.iPhone12_mini_12_Pro)
        case 1920, 2208:
            completion(.iPhones_6Plus_6sPlus_7Plus_8Plus)
        case 1792:
            completion(.iPhoneXR_11)
        case 1334:
            completion(.iPhones_6_6s_7_8)
        case 1136:
            completion(.iphoneSE)
        case 960:
            completion(.iphone4s)
        default:
            completion(.Unknown)
        }
    }
}
let STANDARD_MAX_CONTACT_NO_LENGTH = 15
let STANDARD_MIN_CONTACT_NO_LENGTH = 6
let STR_MAX_ADDR_CHAR = 40
let STR_MAX_ZIPCODE = 10
let STR_MAX_VERIFICATION = 6
let STR_MAX_EXTENSION_NUM = 4
let STR_MAX_CHAR = 50
let STR_MAX_CITY = 30






