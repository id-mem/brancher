struct ShaResponse: Codable {
    let ref: String
    let node_id: String
    let url: String
    let object: ShaObject
}