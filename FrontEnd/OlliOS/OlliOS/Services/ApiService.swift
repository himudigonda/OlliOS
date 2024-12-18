// FrontEnd/OlliOS/OlliOS/Services/ApiService.swift
import Combine
import Foundation
import UniformTypeIdentifiers

class ApiService {
  func fetch<T: Decodable>(from url: URL) -> AnyPublisher<T, Error> {
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.cachePolicy = .reloadIgnoringLocalCacheData

      print("ApiService.swift: Fetching from URL - \(url)")
      print("ApiService.swift: Request headers: \(request.allHTTPHeaderFields ?? [:])")

    return URLSession.shared.dataTaskPublisher(for: request)
      .tryMap { data, response -> Data in
          print("ApiService.swift: Received response")
        guard let httpResponse = response as? HTTPURLResponse,
          200..<300 ~= httpResponse.statusCode
        else {
            print("ApiService.swift: HTTP Error with status code - \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            throw URLError(.badServerResponse)
        }
          print("ApiService.swift: Data fetched successfully")
        return data
      }
        .handleEvents(receiveOutput: { data in
            if let jsonString = String(data: data, encoding: .utf8){
                print("ApiService.swift: Received JSON response: \(jsonString)")
            } else {
                print("ApiService.swift: Received response data: \(data)")
            }
        })
      .decode(type: T.self, decoder: JSONDecoder())
      .eraseToAnyPublisher()
  }

  func post<T: Decodable>(
    to url: URL, body: [String: String], queryParams: [String: String], fileURLs: [URL] = []
  ) -> AnyPublisher<T, Error> {
      print("ApiService.swift: Starting POST request")
      print("ApiService.swift: POST URL - \(url)")
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    // Set up multipart/form-data
    let boundary = UUID().uuidString
      print("ApiService.swift: boundary - \(boundary)")
    request.setValue(
      "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
      urlComponents.queryItems = queryParams.map { key, value in
        URLQueryItem(name: key, value: value)
      }
        print("ApiService.swift: Query parameters - \(String(describing: urlComponents.query))")
      request.url = urlComponents.url
    }

    let httpBody = NSMutableData()

    // Add text fields
    for (key, value) in body {
        print("ApiService.swift: Adding text field - \(key) with value - \(value)")
      httpBody.appendString(string: "--\(boundary)\r\n")
      httpBody.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
      httpBody.appendString(string: "\(value)\r\n")
    }

    // Add files if they exist
    for fileURL in fileURLs {
        print("ApiService.swift: Processing file - \(fileURL.lastPathComponent)")
      if let fileData = try? Data(contentsOf: fileURL) {
        let fileMimeType = getMimeType(for: fileURL)
          print("ApiService.swift: File mimeType - \(fileMimeType)")
        httpBody.appendString(string: "--\(boundary)\r\n")
        httpBody.appendString(
          string:
            "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n"
        )
        httpBody.appendString(string: "Content-Type: \(fileMimeType)\r\n\r\n")
        httpBody.append(fileData)
        httpBody.appendString(string: "\r\n")
      }
    }

    // End the multipart form
    httpBody.appendString(string: "--\(boundary)--\r\n")
    request.httpBody = httpBody as Data

      print("ApiService.swift: Full request body size: \(request.httpBody?.count ?? 0) bytes")

    print(
      "ApiService.swift: Posting to URL - \(url) with body - \(body) and queryParams - \(queryParams) and files - \(fileURLs.map { $0.lastPathComponent }.joined(separator: ", "))"
    )
      print("ApiService.swift: Request headers: \(request.allHTTPHeaderFields ?? [:])")

    return URLSession.shared.dataTaskPublisher(for: request)
      .tryMap { data, response -> Data in
          print("ApiService.swift: Received response after POST")
        guard let httpResponse = response as? HTTPURLResponse,
          200..<300 ~= httpResponse.statusCode
        else {
            print("ApiService.swift: HTTP Error with status code - \((response as? HTTPURLResponse)?.statusCode ?? -1)")
          throw URLError(.badServerResponse)
        }
          print("ApiService.swift: Data posted successfully")
        return data
      }
        .handleEvents(receiveOutput: { data in
            if let jsonString = String(data: data, encoding: .utf8){
                print("ApiService.swift: Received JSON response: \(jsonString)")
            } else {
                print("ApiService.swift: Received response data: \(data)")
            }
        })
      .decode(type: T.self, decoder: JSONDecoder())
      .eraseToAnyPublisher()
  }

  private func getMimeType(for fileURL: URL) -> String {
    if let type = UTType(filenameExtension: fileURL.pathExtension) {
      return type.preferredMIMEType ?? "application/octet-stream"
    }
    return "application/octet-stream"
  }
}

extension NSMutableData {
  func appendString(string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}
