//
//  MovieListModel.swift
//  TheMoviesList
//
//  Created by Annapurna Relan on 19/04/22.
//

import Foundation


struct MovieListModel: Codable{
    
    let errorData : ErrorData?
        let responseData : [ResponseData]?
        let responseMessage : ResponseMessage?
        let title : String?
        let type : String?


        enum CodingKeys: String, CodingKey {
            case errorData
            case responseData = "responseData"
            case responseMessage
            case title = "title"
            case type = "type"
        }
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            errorData = try ErrorData(from: decoder)
            responseData = try values.decodeIfPresent([ResponseData].self, forKey: .responseData)
            responseMessage = try ResponseMessage(from: decoder)
            title = try values.decodeIfPresent(String.self, forKey: .title)
            type = try values.decodeIfPresent(String.self, forKey: .type)
        }
}

struct ResponseMessage : Codable {

    let httpStatus : Int?
        let landingTime : String?
        let message : String?
        let responseTime : String?
        let status : Int?


        enum CodingKeys: String, CodingKey {
            case httpStatus = "httpStatus"
            case landingTime = "landingTime"
            case message = "message"
            case responseTime = "responseTime"
            case status = "status"
        }
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            httpStatus = try values.decodeIfPresent(Int.self, forKey: .httpStatus)
            landingTime = try values.decodeIfPresent(String.self, forKey: .landingTime)
            message = try values.decodeIfPresent(String.self, forKey: .message)
            responseTime = try values.decodeIfPresent(String.self, forKey: .responseTime)
            status = try values.decodeIfPresent(Int.self, forKey: .status)
        }
 }

struct ResponseData : Codable {

    let descriptionField : String?
    let id : Int?
    let image : String?
    let movieName : String?


    enum CodingKeys: String, CodingKey {
        case descriptionField = "description"
        case id = "id"
        case image = "image"
        case movieName = "movieName"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        descriptionField = try values.decodeIfPresent(String.self, forKey: .descriptionField)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        movieName = try values.decodeIfPresent(String.self, forKey: .movieName)
    }


}
struct ErrorData : Codable {
    enum CodingKeys: CodingKey {
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
    }
}
