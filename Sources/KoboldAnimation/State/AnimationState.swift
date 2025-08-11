public class AnimationState {
    let defaultClip: String
    let playbackSpeed: Float
    let clips: [String: KAClip]
    public let skeleton: KASkeleton
    public let pose: KAPose

    private var currentClipName: String
    private var animationTime: Float

    public init(
        skeleton: KASkeleton,
        clips: [String: KAClip],
        playbackSpeed: Float = 1,
        defaultClip: String? = nil
    ) {
        self.defaultClip = defaultClip ?? clips.keys.sorted().first!
        self.skeleton = skeleton
        self.clips = clips
        self.pose = skeleton.bindPose.clone()
        self.currentClipName = self.defaultClip
        self.animationTime = 0
        self.playbackSpeed = playbackSpeed
        self.resetAnimation()
    }

    public func animate(_ deltaTime: Float) {
        if let clip = clips[currentClipName] {
            animationTime = clip.sample(pose: pose, inTime: animationTime + deltaTime * playbackSpeed)
        }
    }

    public func changeClip(_ clipName: String) {
        currentClipName = clipName
        animationTime = 0
        animate(0)
    }

    public func currentClip() -> String {
        return currentClipName
    }

    public func resetAnimation() {
        changeClip(defaultClip)
    }
}
