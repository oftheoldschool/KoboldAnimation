public struct KAMeshAnimationChannel {
    let id: Int
    let interpolation: KAMeshAnimationChannelInterpolation
    let time: [Float]
    let type: KAMeshAnimationChannelType

    public init(
        id: Int,
        interpolation: KAMeshAnimationChannelInterpolation,
        time: [Float],
        type: KAMeshAnimationChannelType
    ) {
        self.id = id
        self.interpolation = interpolation
        self.time = time
        self.type = type
    }
}
