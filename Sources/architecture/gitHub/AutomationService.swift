import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct AutomationService {
    static func createBranch(repository: Repository, token: String, owner: String, sha: String)
        async throws
    {
        guard
            let url = URL(
                string: "https://api.github.com/repos/\(owner)/\(repository.name)/git/refs")
        else {
            Logger.logAutomationError(
                AutomationError.branchCreationError("Invalid URL for creating branch"))
            exit(EXIT_FAILURE)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

        let requestBody: [String: String] = [
            "ref": "refs/heads/\(repository.newBranch)",
            "sha": sha,
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            Logger.logAutomationError(
                AutomationError.jsonParsingError(
                    "Failed to serialize request body for branch creation"))
            exit(EXIT_FAILURE)
        }

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            Logger.logAutomationError(
                AutomationError.branchCreationError(
                    "Failed to create branch \(repository.newBranch) for \(repository.name)"))
            return
        }
        Logger.logSuccess("Branch \(repository.newBranch) created successfully for \(repository.name)")
    }

    static func retrieveSha(repository: Repository, token: String, owner: String) async throws
        -> String
    {
        guard
            let url = URL(
                string:
                    "https://api.github.com/repos/\(owner)/\(repository.name)/git/refs/heads/\(repository.branch)"
            )
        else {
            Logger.logAutomationError(
                AutomationError.branchCreationError("Invalid URL for SHA retrieval"))
            exit(EXIT_FAILURE)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        do {
            let shaResponse = try JSONDecoder().decode(ShaResponse.self, from: data)
            return shaResponse.object.sha
        } catch {
            let errorMessage = "Failed to decode SHA response: \(error.localizedDescription)"
            Logger.logAutomationError(
                AutomationError.jsonParsingError(errorMessage))
            throw AutomationError.jsonParsingError(errorMessage)
        }
    }

    static func parseInitialFile(filePath: String) -> AutoConfiguration {
        let fileName = (filePath as NSString).lastPathComponent
        guard filePath.hasSuffix(".json") else {
            Logger.logAutomationError(
                AutomationError.invalidFilePath("Requires JSON file: \(filePath)"))
            exit(EXIT_FAILURE)
        }

        do {
            let fileURL = URL(fileURLWithPath: filePath)
            let fileData = try Data(contentsOf: fileURL)
            Logger.logInfo("Successfully read data from \(fileName)")
            do {
                let decoder = JSONDecoder()
                let config = try decoder.decode(AutoConfiguration.self, from: fileData)
                Logger.logInfo("Successfully decoded JSON from \(fileName)")
                return config
            } catch {
                Logger.logAutomationError(
                    AutomationError.jsonParsingError(
                        "Failed to decode JSON from \(fileName): \(error.localizedDescription)"))
                exit(EXIT_FAILURE)
            }
        } catch {
            Logger.logAutomationError(
                AutomationError.fileNotFound("File not found at path: \(filePath)"))
            exit(EXIT_FAILURE)
        }
    }
}
