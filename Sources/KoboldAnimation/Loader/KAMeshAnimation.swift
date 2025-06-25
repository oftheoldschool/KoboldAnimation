public struct KAMeshAnimation {
    let name: String
    let channels: [KAMeshAnimationChannel]

    public init(
        name: String,
        channels: [KAMeshAnimationChannel]
    ) {
        self.name = name
        self.channels = channels
    }
}
