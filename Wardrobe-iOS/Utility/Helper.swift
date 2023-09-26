//
//  Helper.swift
//  Wardrobe-iOS
//
//  Created by Eduard Minasyan on 4/4/20.
//  Copyright © 2020 Eduard Minasyan. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift


enum RequestResponseType {
    case start(showLoading: Bool)
    case fail(showPopup: Bool)
    case success(response: Any?)
}

protocol RequestResponseProtocol {
    func start(showLoading: Bool)
    func fail(showPopup: Bool)
    func success(response: Any?)
}

enum GradientOrientation {
    case horizontal
    case vertical
}

func isSignIn() -> Bool {
    return CredentialsStorage.credentialWithKey(.authToken) != nil
}

func haveConnection() -> Bool {
    return UIApplication.appDelegate.reachabilityHandler.haveConnection()
}

func getRegionCode() -> String {
    let locale = Locale.current
    return locale.regionCode ?? "123"
}

func getLanguageCode() -> String {
    let locale = NSLocale.current
    return locale.languageCode!
}

func getDeviceName() -> String {
    return UIDevice.current.name
}

func getAppVersion() -> String {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    return appVersion!
}

func getosVersion() -> String {
    return UIDevice.current.systemVersion
}

func platformId() -> Int {
    return 1
}

func getDeviceToken() -> String {
    return UIDevice.current.identifierForVendor!.uuidString
}

func getPushToken() -> String? {
    if let pushToken = UserDefaults.standard.object(forKey: UserDefaultsKey.push) as? String {
        return pushToken
    }
    return nil
}

func generateRandomId() -> String {
    return UUID().uuidString
}

func getNavigationTitle(_ first: String, _ second: String) -> NSAttributedString {
    let titleAttibutedString = NSMutableAttributedString(string: first + " ", attributes: [.foregroundColor: SCColors.titleColor, .font: UIFont.boldSystemFont(ofSize: 30)])
    titleAttibutedString.append(NSAttributedString(string: second, attributes: [.foregroundColor: SCColors.titleColor, .font: UIFont.monospacedDigitSystemFont(ofSize: 30, weight: .light)]))
    return titleAttibutedString
}

func searchedAttibutedString(text: String, deletedStrings: [String]) -> NSAttributedString {
    let attibutedString = NSMutableAttributedString(string: text, attributes: [.foregroundColor: SCColors.mainGrayColor, .font: UIFont.systemFont(ofSize: 17)])
    deletedStrings.forEach { (string) in
        if let range = text.range(of: string, options: .caseInsensitive) {
            attibutedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: range.lowerBound.utf16Offset(in: string), length: string.count))
        }
    }
    return attibutedString
}

func createAttributedWithWeather(_ weatherModel: WeatherModel) -> NSAttributedString {
    let weatherAttributeString = NSMutableAttributedString(string: "")
    let weatherIcon = NSTextAttachment()
    let image = UIImage(named: weatherModel.icon)
    weatherIcon.image = image
    weatherIcon.bounds = CGRect(x: 0, y: -14, width: 40, height: 40)
    let weatherIconString = NSAttributedString(attachment: weatherIcon)
    let weatherString = " " + weatherModel.tempCelsius + " " +  weatherModel.city
    let attributedString = NSAttributedString(string: weatherString, attributes: [.font: UIFont.systemFont(ofSize: 13), .foregroundColor: SCColors.titleColor])
    weatherAttributeString.append(weatherIconString)
    weatherAttributeString.append(attributedString)
    return weatherAttributeString
}

func createAttributedWithNoWeather() -> NSAttributedString {
    let weatherAttributeString = NSMutableAttributedString(string: "")
    let weatherIcon = NSTextAttachment()
    let image = UIImage(named: "noWeather")
    weatherIcon.image = image
    weatherIcon.bounds = CGRect(x: 0, y: -4, width: 24, height: 20)
    let weatherIconString = NSAttributedString(attachment: weatherIcon)
    let weatherString = "   " + "No Data".localize()
    let attributedString = NSAttributedString(string: weatherString, attributes: [.font: UIFont.systemFont(ofSize: 13), .foregroundColor: SCColors.mainGrayColor])
    weatherAttributeString.append(weatherIconString)
    weatherAttributeString.append(attributedString)
    return weatherAttributeString
}

func errorMessageAttribute(title: String, desc: String) -> NSAttributedString {
    let attributeString = NSMutableAttributedString(string: title.localize() + "\n", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .semibold), .foregroundColor: SCColors.deleteColor])
    attributeString.append(NSAttributedString(string: desc.localize(), attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: SCColors.deleteColor]))
    return attributeString
}

func localTimeIntervalToUTC(timeInterval: Double) -> Int {
    let timezoneOffset =  TimeZone.current.secondsFromGMT()
    let interval = timeInterval + Double(timezoneOffset)
    return Int(interval) * 1000
}


