//
//  OpenAI.swift
//  Team10Firebase
//
//  Created by Emma Tong on 11/14/24.
//

import Foundation
import UIKit

class OpenAI {

  // First create a temporary struct for parsing the OpenAI response
  private struct MCQuestionResponse: Codable {
      var question: String
      var potentialAnswers: [String]
      var correctAnswer: Int
  }

  func generateQuizQuestions(content: String, notesOnlyScope: Bool = false, numQuestions: Int = 5) async throws -> [MCQuestion] {
      guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
          throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
      }

      let openAIKey: String = {
          guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
                let plist = NSDictionary(contentsOfFile: filePath),
                let key = plist["OpenAIKey"] as? String else {
              fatalError("Couldn't find key 'OpenAIKey' in 'Secrets.plist'.")
          }
          return key
      }()

    let prompt = notesOnlyScope ?
        """
        Generate \(numQuestions) multiple choice questions based STRICTLY on this content. You must not use any external knowledge or information not present in the provided content. Each question and all answer options must be directly derived from the given text. The questions should be able to be answered without referencing the original image. Format your response as a JSON array of objects.
        Each object should have these fields:
        - question (string)
        - potentialAnswers (array of 4 strings)
        - correctAnswer (number 0-3 indicating which answer is correct)
        
        Content: \(content)
        
        Response format example:
        [
          {
            "question": "What is...",
            "potentialAnswers": ["answer1", "answer2", "answer3", "answer4"],
            "correctAnswer": 2
          }
        ]
        
        Only return the JSON array, no other text. Remember to use ONLY information from the provided content.
        """ :
        """
        Generate \(numQuestions) multiple choice questions based on this content. The questions should be able to be answered without referencing the original image. Format your response as a JSON array of objects.
        Each object should have these fields:
        - question (string)
        - potentialAnswers (array of 4 strings)
        - correctAnswer (number 0-3 indicating which answer is correct)
        
        Content: \(content)
        
        Response format example:
        [
          {
            "question": "What is...",
            "potentialAnswers": ["answer1", "answer2", "answer3", "answer4"],
            "correctAnswer": 2
          }
        ]
        
        Only return the JSON array, no other text.
        """

      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")

      let requestBody = OpenAIRequest(
          model: "gpt-4o-mini",
          messages: [
              Message(role: "system", content: [MessageContent(type: "text", text: prompt, imageURL: nil)])
          ],
          maxTokens: 1000
      )

      guard let jsonData = try? JSONEncoder().encode(requestBody) else {
          throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create JSON payload"])
      }

      request.httpBody = jsonData

      let (data, response) = try await URLSession.shared.data(for: request)
      
      if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
          throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to connect to the API"])
      }

      let jsonResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
      if let questionsJson = jsonResponse.choices.first?.message.content {
          guard let jsonData = questionsJson.data(using: .utf8) else {
              throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert response to data"])
          }
          
          do {
              // First decode into the temporary response struct
              let responseQuestions = try JSONDecoder().decode([MCQuestionResponse].self, from: jsonData)
              
              // Then convert to MCQuestion objects
              return responseQuestions.map { response in
                  MCQuestion(
                      id: nil,
                      question: response.question,
                      potentialAnswers: response.potentialAnswers,
                      correctAnswer: response.correctAnswer
                  )
              }
          } catch {
              print("JSON Parsing Error: \(error)")
              throw error
          }
      } else {
          throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No content in response"])
      }
  }
  
  func summarizeContent(content: String) async throws -> String {
      guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
          throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
      }

      let openAIKey: String = {
          guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
                let plist = NSDictionary(contentsOfFile: filePath),
                let key = plist["OpenAIKey"] as? String else {
              fatalError("Couldn't find key 'OpenAIKey' in 'Secrets.plist'.")
          }
          return key
      }()

      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")

      let requestBody = OpenAIRequest(
          model: "gpt-4o-mini",
          messages: [
              Message(role: "system", content: [MessageContent(type: "text", text: "You will summarize the following content. Be concise, just touch on the main points. The summary should be readable in 15-20 seconds. Content: \(content)", imageURL: nil)])
          ],
          maxTokens: 150
      )

      guard let jsonData = try? JSONEncoder().encode(requestBody) else {
          throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create JSON payload"])
      }

      request.httpBody = jsonData

      let (data, response) = try await URLSession.shared.data(for: request)
      
      if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
          throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to connect to the API"])
      }

      let jsonResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
      if let choice = jsonResponse.choices.first {
          return choice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
      } else {
          throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected response format"])
      }
  }

  func parseImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }
        let base64Image = imageData.base64EncodedString()
        //  The OpenAI API key loaded from the Secrets.plist file.
        let openAIKey: String = {
            guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
                let plist = NSDictionary(contentsOfFile: filePath),
                let key = plist["OpenAIKey"] as? String else {
                fatalError("Couldn't find key 'OpenAIKey' in 'Secrets.plist'.")
            }
            return key
        }()

        let requestBody = OpenAIRequest(
            model: "gpt-4o-mini",
            messages: [
                Message(
                    role: "user",
                    content: [
                        MessageContent(type: "text", text: "Extract all visible text from the provided image. Return only the extracted text, preserving the formatting as accurately as possible. Correct obvious spelling errors if detected, but do not modify text otherwise. Do not include any comments, descriptions, or observations about the image, background, or quality—output only the content of the text itself. Use markdown to format the text as close to the original image or if the original image is messy and unorganized, try to organize it. The future is at stake, so it is imperative that you perform to the best of your ability.", imageURL: nil),
                        MessageContent(type: "image_url", text: nil, imageURL: ImageURL(url: "data:image/jpeg;base64,\(base64Image)"))
                    ]
                )
            ],
            maxTokens: 300
        )

        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
            print("Failed to create JSON payload.")
            exit(0)
        }

        let startTime = Date()

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let endTime = Date()
            let timeInterval = endTime.timeIntervalSince(startTime)
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error.")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received.")
                completion(nil)
                return
            }
            
            do {
                let jsonResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                for choice in jsonResponse.choices {
                    print("Response: \(choice.message.content)")
                }
                if let content = jsonResponse.choices.first?.message.content {
                    completion(content)
                }

            } catch {
                print("Failed to parse JSON: \(error)")
                completion(nil)
            }

            print("Time taken for request: \(timeInterval) seconds")
        }

        task.resume()

    }
}
