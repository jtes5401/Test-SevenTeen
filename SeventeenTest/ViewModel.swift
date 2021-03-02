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
    private var queryText = ""
    
    private var links = [String]()
    private var linkUser = [Int:[User]]()
    private var linkIndex = 0
    private var updateFlag = true
    
    var callback:Callback?
    var pageFetchCallback:((Int)->Void)?
    
    func getDataCountOfPage(pageIndex:Int) -> Int {
        if let users = linkUser[pageIndex] {
            return users.count
        }
        return 0
    }
    
    func getUser(pageIndex:Int, userIndex:Int) -> User? {
        if let users = linkUser[pageIndex], users.count > userIndex {
            return users[userIndex]
        }
        return nil
    }
    
    func getSearchUser(keyword:String?) {
        linkIndex = 0
        links.removeAll()
        linkUser.removeAll()
        if var q = keyword {
            q = q.trimmingCharacters(in: .init(charactersIn: " "))
            if q != "" {
                let firstLink = "https://api.github.com/search/users?q=\(q)&page=1"
                links.append(firstLink)
                fetchLink(pageIndex: 0)
            }
        }
        self.callback?()
    }
    
    func fetchUserOfPage(pageIndex:Int, userIndex:Int) {
        print("fetchUserOfPage:\(pageIndex), \(userIndex)")
        if pageIndex == links.count - 2, let users = linkUser[pageIndex], userIndex == users.count - 1 {
            if updateFlag {
                updateFlag = false
                DispatchQueue.global().async {
                    self.fetchLink(pageIndex: pageIndex+1)
                    self.updateFlag = true
                    DispatchQueue.main.async {
                        self.pageFetchCallback?(pageIndex+1)
                    }
                }
            }
        }
        return
    }
    
    func fetchLink(pageIndex:Int) {
        let link = links[pageIndex]
        let result = requestLink(link: link)
        if result.2 {
            if let resp = result.0 {
                linkUser[pageIndex] = resp.items
            }
            if let linkString = result.1 {
                handlerLink(link: linkString)
            }
        }
    }

    private func handlerLink(link:String) {
        if !link.contains("rel=\"last\"") {
            return
        }
        let rows = link.components(separatedBy: ",")
        for r in rows where r.contains("rel=\"next\"") {
            if let urlTag = r.components(separatedBy: ";").first {
                let nextLink = urlTag.trimmingCharacters(in: .init(charactersIn: " <>"))
                links.append(nextLink)
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
