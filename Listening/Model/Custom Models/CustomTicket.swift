//
//  CustomTickets.swift
//  Listening
//
//  Created by huydoquang on 3/4/18.
//  Copyright © 2018 huydoquang. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST

class CustomTicket {
    var tickets: [GTLRServiceTicket?]
    
    init(tickets: [GTLRServiceTicket?]) {
        self.tickets = tickets
    }
    
    func cancel() {
        self.tickets.forEach {$0?.cancel()}
    }
}
