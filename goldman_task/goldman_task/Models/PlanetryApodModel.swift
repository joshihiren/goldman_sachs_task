//
//  PlanetryApodModel.swift
//  Task
//
//  Created by Hiren Joshi on 07/21/22.
//

import Foundation

struct PlanetryApodModel : Codable {
    
    let copyright : String?
    let date : String?
    let explanation: String?
    let hdurl: String?
    let media_type: String?
    let service_version: String?
    let title: String?
    let url: String?
    let fav_Status: String?
    
    enum CodingKeys: String, CodingKey {
        case copyright = "copyright"
        case date = "date"
        case explanation = "explanation"
        case hdurl = "hdurl"
        case media_type = "media_type"
        case service_version = "service_version"
        case title = "title"
        case url = "url"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        copyright = try values.decodeIfPresent(String.self, forKey: .copyright)
        date = try values.decodeIfPresent(String.self, forKey: .date)
        explanation = try values.decodeIfPresent(String.self, forKey: .explanation)
        hdurl = try values.decodeIfPresent(String.self, forKey: .hdurl)
        media_type = try values.decodeIfPresent(String.self, forKey: .media_type)
        service_version = try values.decodeIfPresent(String.self, forKey: .service_version)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        fav_Status = "0"
    }
    
    init(fromDictionary dictionary: [String:Any]) {
        copyright = dictionary[Kcopyright] as? String
        date = dictionary[Kdate] as? String
        explanation = dictionary[Kexplanation] as? String
        hdurl = dictionary[Khdurl] as? String
        media_type = dictionary[Kmedia_type] as? String
        service_version = dictionary[Kservice_version] as? String
        title = dictionary[Ktitle] as? String
        url = dictionary[Kurl] as? String
        fav_Status = dictionary[Kfav_Status] as? String ?? "0"
    }
    
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if copyright != nil{
            dictionary[Kcopyright] = copyright
        }
        if date != nil{
            dictionary[Kdate] = date
        }
        if explanation != nil{
            dictionary[Kexplanation] = explanation
        }
        if hdurl != nil{
            dictionary[Khdurl] = hdurl
        }
        if media_type != nil{
            dictionary[Kmedia_type] = media_type
        }
        if service_version != nil{
            dictionary[Kservice_version] = service_version
        }
        if title != nil{
            dictionary[Ktitle] = title
        }
        if url != nil{
            dictionary[Kurl] = url
        }
        if fav_Status != nil{
            dictionary[Kfav_Status] = fav_Status ?? "0"
        }
        return dictionary
    }
    
}
