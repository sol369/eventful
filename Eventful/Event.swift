//
//  Event.swift
//  Eventful
//
//  Created by Shawn Miller on 8/12/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot


struct  Event: Keyed {
    var key: String?
    let currentEventName: String
    let currentEventImage: String
    let currentEventPromo: String?
    let currentEventDescription: String
    //nested properties
    let currentEventStreetAddress: String
    let currentEventCity: String
    let currentEventState: String
    let currentEventDate: String?
    let currentEventTime: String?
    let currentEventZip: Int
    //nested properties stop
    var currentAttendCount: Int
    var isAttending = false
    var eventDictionary: [String: Any]{
        
        
        let dateDict = ["start:date":currentEventDate, "start:time": currentEventTime]
        
        return ["event:name":currentEventName,"event:imageURL" : currentEventImage,
                "event:description": currentEventDescription, "attend:count": currentAttendCount,
                "event:street:address": currentEventStreetAddress,"event:zip": currentEventZip,
                "event:state": currentEventState, "event:city": currentEventCity, "event:promo": currentEventPromo ?? "", "event:date": dateDict]
    }
    
    init(currentEventKey: String, dictionary: [String:Any]) {
        self.key = currentEventKey
        self.currentEventName = dictionary["event:name"] as? String ?? ""
        self.currentEventImage = dictionary["event:imageURL"] as? String ?? ""
        self.currentEventDescription = dictionary["event:description"] as? String ?? ""
        self.currentEventPromo = dictionary["event:promo"] as? String ?? ""
        self.currentAttendCount = dictionary["attend:count"] as? Int ?? 0
        //nested properties
        self.currentEventStreetAddress = dictionary["event:street:address"] as? String ?? ""
        self.currentEventCity = dictionary["event:city"] as? String ?? ""
        self.currentEventState = dictionary["event:state"] as? String ?? ""
        self.currentEventZip = dictionary["event:zip"] as? Int ?? 0
        let eventDate = dictionary["event:date"] as? [String: Any]
        self.currentEventDate = eventDate?["start:date"] as? String ?? ""
        self.currentEventTime = eventDate?["start:time"] as? String ?? ""
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let currentEventName = dict["event:name"] as? String,
            let currentEventImage = dict["event:imageURL"] as? String,
            let currentEventDescription = dict["event:description"] as? String,
            let currentEventPromo = dict["event:promo"] as? String,
            let currentEventStreetAddress = dict["event:street:address"] as? String,
            let currentEventCity = dict["event:city"] as? String,
            let currentEventState = dict["event:state"] as? String,
            let currentEventZip = dict["event:zip"] as? Int,
            let currentAttendCount = dict["attend:count"] as? Int,
            let eventDate = dict["event:date"] as? [String: Any],
            let currentEventDate = eventDate["start:date"] as? String,
            let currentEventTime = eventDate["start:time"] as? String
            else { return nil }
        self.key = snapshot.key
        self.currentEventName = currentEventName
        self.currentEventImage = currentEventImage
        self.currentEventDescription = currentEventDescription
        self.currentEventStreetAddress = currentEventStreetAddress
        self.currentEventCity = currentEventCity
        self.currentEventState = currentEventState
        self.currentEventZip = currentEventZip
        self.currentAttendCount = currentAttendCount
        self.currentEventPromo = currentEventPromo
        self.currentEventDate = currentEventDate
        self.currentEventTime = currentEventTime
    }
    
    
 
    
    
}
