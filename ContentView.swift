//
//  POC Swift app that performs a Purple Air sensor query
//
import SwiftUI

struct ContentView: View {
    @State private var sensor: PurpleAirWrapper?
    var body: some View {
        VStack {
            Text(sensor?.time_stamp.description ?? "Time stamp placeholder")
            Text(sensor?.sensor.temperature.description ?? "Temp placeholder")
         }
        .padding()
        .task {
            do {
                sensor = try await getSensorData()
            } catch PurpleAirError.invalidURL {
                print("Invalid URL")
            } catch PurpleAirError.invalidResponse {
                print("Invalid Response")
            } catch PurpleAirError.invalidData {
                print("Invalid Data")
            } catch {
                print("Unexpected Error")
            }
        }
    }
}

func getSensorData() async throws -> PurpleAirWrapper {
    let endpoint = "https://api.purpleair.com/v1/sensors/<SENSOR ID>"  
    var url = URLComponents(string: endpoint)!
    url.queryItems = [
        URLQueryItem(name: "fields", value: "temperature")
    ]
      
    var request = URLRequest(url: url.url!)
    
    request.setValue("<YOUR API KEY>", forHTTPHeaderField: "X-API-Key")
    
    let (data, response) = try await URLSession.shared.data(for: request)

    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        print(String(data: data, encoding: .utf8)!)
        throw PurpleAirError.invalidResponse
    }

    do {
        print(String(data: data, encoding: .utf8)!)
        let decoder = JSONDecoder()
        // TO DO: Handle snake case
        // decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(PurpleAirWrapper.self, from: data)
    } catch {
          throw PurpleAirError.invalidData
    }
}

#Preview {
    ContentView()
}

// Data model
// Should be moved to another file
struct PurpleAirWrapper: Codable {
    struct SensorData: Codable {
        let sensor_index: Int
        let temperature: Int
    }
    let api_version: String
    let time_stamp: Int
    let data_time_stamp: Int
    let sensor: SensorData
}

// Error cases
enum PurpleAirError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    
}
