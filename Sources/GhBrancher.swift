import Foundation

@main
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct Main {
    static func main() async throws {
        guard CommandLine.arguments.count == 2 else {
            print("Usage: GhBrancher <path_to_initial_file>")
            exit(EXIT_FAILURE)
        }

        let filePath = CommandLine.arguments[1]

        Logger.startup(file: filePath)

        let autoConfig = AutomationService.parseInitialFile(filePath: filePath)

        for repository in autoConfig.repositories {
            do {
                let sha = try await AutomationService.retrieveSha(
                    repository: repository, token: autoConfig.token, owner: autoConfig.owner)
                try await AutomationService.createBranch(
                    repository: repository, token: autoConfig.token, owner: autoConfig.owner,
                    sha: sha)
            } catch {
                print("An error has occured: \(error)")
                exit(EXIT_FAILURE)
            }
        }
    }
}
