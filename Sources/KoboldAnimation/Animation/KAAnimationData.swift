public struct KAAnimationData {
    public let skeleton: KASkeleton
    public let animations: [String: KAClip]

    init(
        skeleton: KASkeleton,
        animations: [String : KAClip]
    ) {
        self.skeleton = skeleton
        self.animations = animations
    }
}
