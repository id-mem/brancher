struct AutoConfiguration: Codable {
    var owner: String;
    var token: String;
    var repositories: [Repository]
}