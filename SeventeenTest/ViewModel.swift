//
//  ViewModel.swift
//  SeventeenTest
//
//  Created by Wei Kuo on 2021/2/25.
//

import Foundation
import Alamofire

typealias Callback = (()->Void)

class ViewModel {
    private(set) var dataCount = 0
    private(set) var dataUsers = [User]()
    private var queryText = ""
    private var nextLink = ""
    
    var callback:Callback?
    
    func getSearchUser(keyword:String?) {
        dataUsers.removeAll()
        dataCount = 0
        if var q = keyword {
            q = q.trimmingCharacters(in: .init(charactersIn: " "))
            if q != "" {
                nextLink = "https://api.github.com/search/users?q=\(q)&page=1"
                fetchLink(isFirst: true)
            }
        }
        self.callback?()
    }
    
    func fetchLink(isFirst:Bool) {
        let result = requestLink(link: nextLink)
        if result.2 {
            if let resp = result.0 {
                dataUsers.append(contentsOf: resp.items)
                if isFirst {
                    dataCount = resp.total_count
                }
            }
            if let linkString = result.1 {
                handlerLink(link: linkString)
            }
        }
    }
    
    
    func getUser(userIndex:Int) -> User? {
        while userIndex > dataUsers.count {
            fetchLink(isFirst: false)
        }
        if userIndex >= dataUsers.count {
            return nil
        }
        
        return dataUsers[userIndex]
    }

    private func handlerLink(link:String) {
        let isLast = !link.contains("rel=\"last\"")
        if isLast {
            nextLink = ""
            return
        }
        let rows = link.components(separatedBy: ",")
        for r in rows where r.contains("rel=\"next\"") {
            if let urlTag = r.components(separatedBy: ";").first {
                nextLink = urlTag.trimmingCharacters(in: .init(charactersIn: " <>"))
            }
        }
    }
    
    private func requestLink(link:String) -> (SearchUserResponse?,String?,Bool) {
        print("requestLink:",link)
        var resultTuple:(SearchUserResponse?,String?,Bool) = (nil,nil,false)
        let sema = DispatchSemaphore(value:0)
        AF.request(link).responseDecodable(of: SearchUserResponse.self, queue: .global()) { response in
            switch response.result {
            case .success(let resp):
                resultTuple.0 = resp
                resultTuple.1 = response.response?.headers.value(for: "Link")
                resultTuple.2 = true
            case .failure(let err):
                print("Request:",err)
            }
            sema.signal()
        }
        sema.wait()
        return resultTuple
    }
    
}
