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

    return URLSession.shared.dataTaskPublisher(for: request)
      .tryMap { data, response -> Data in
        guard let httpResponse = response as? HTTPURLResponse,
          200..<300 ~= httpResponse.statusCode
        else {
          throw URLError(.badServerResponse)
        }
        print("ApiService.swift: Data fetched successfully")
        return data
      }
      .decode(type: T.self, decoder: JSONDecoder())
      .eraseToAnyPublisher()
  }

  func post<T: Decodable>(
    to url: URL, body: [String: String], queryParams: [String: String], fileURLs: [URL] = []
  )
    -> AnyPublisher<T, Error>
  {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    // Set up multipart/form-data
    let boundary = UUID().uuidString
    request.setValue(
      "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
      urlComponents.queryItems = queryParams.map { key, value in
        URLQueryItem(name: key, value: value)
      }
      request.url = urlComponents.url
    }

    let httpBody = NSMutableData()

    // Add text fields
    for (key, value) in body {
      httpBody.appendString(string: "--\(boundary)\r\n")
      httpBody.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
      httpBody.appendString(string: "\(value)\r\n")
    }

    // Add files if they exist
    for fileURL in fileURLs {
      if let fileData = try? Data(contentsOf: fileURL) {
        let fileMimeType = getMimeType(for: fileURL)
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

    print(
      "ApiService.swift: Posting to URL - \(url) with body - \(body) and queryParams - \(queryParams) and files - \(fileURLs.map { $0.lastPathComponent }.joined(separator: ", "))"
    )

    return URLSession.shared.dataTaskPublisher(for: request)
      .tryMap { data, response -> Data in
        guard let httpResponse = response as? HTTPURLResponse,
          200..<300 ~= httpResponse.statusCode
        else {
          throw URLError(.badServerResponse)
        }
        print("ApiService.swift: Data posted successfully")
        return data
      }
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
