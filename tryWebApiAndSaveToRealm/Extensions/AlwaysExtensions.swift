//
//  Extensions.swift
//  tryToAppendDataToFile
//
//  Created by Marko Dimitrijevic on 12/09/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import Foundation

extension FileManager {
    static var docDirUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    static var historyUrl: URL {
        return FileManager.docDirUrl.appendingPathComponent("questionsHistory").appendingPathExtension("txt")
    }
}

extension Date {
    static var now: Date {
        return Date.init(timeIntervalSinceNow: 0)
    }
}

// ovo koristi svuda !!!

extension Data {
    var toString: String? {
        return String(data: self, encoding: String.Encoding.utf8)
    }
}

extension String {
    var toData: Data? {
        return self.data(using: String.Encoding.utf8)
    }
}

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

extension DateFormatter {
    
    convenience init(format: String) {
        self.init()
        dateFormat = format
        locale = Locale.current
    }
}

extension String {
    
    func toDate(format: String) -> Date? {
        return DateFormatter(format: format).date(from: self)
    }
    
    func toDateString(inputFormat: String, outputFormat:String) -> String? {
        if let date = toDate(format: inputFormat) {
            return DateFormatter(format: outputFormat).string(from: date)
        }
        return nil
    }
}

extension Date { // (*)
    
    func toString(format:String) -> String? {
        return DateFormatter(format: format).string(from: self)
    }
    
    static var defaultFormatString = "yyyy-MM-dd HH:mm:ss"
}

extension Date { // (*)
    
    static func parse(_ string: String, format: String = "yyyy-MM-dd HH:mm:ss") -> Date {
//        print("string = \(string)")
        let dateFormatter = DateFormatter()
        
        //dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format
//        print("parsedDate from string = \(dateFormatter.date(from: string)!)")
        return dateFormatter.date(from: string)!
    }
    
    static func parseIntoTime(_ string: String, outputWithSeconds: Bool, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        
        let date = parse(string, format: format)
        
        let formatter = DateFormatter()
        
        formatter.dateStyle = .none
        
        formatter.timeStyle = outputWithSeconds ? .medium : .short
        
        return formatter.string(from: date).components(separatedBy: " ").first ?? ""
        
    }
    
    static func parseIntoDateOnly(_ string: String, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        
        let date = parse(string, format: format)
        
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        
        formatter.timeStyle = .none
        
        return formatter.string(from: date)//.components(separatedBy: " ").first ?? ""
        
    }
    
}
