public class AnimationState {
    let defaultClip: String
    let defaultOffset: Float
    let clips: [String: KAClip]
    public let skeleton: KASkeleton
    public let pose: KAPose

    private var playbackSpeed: Float
    private var looping: Bool
    private var currentClipName: String
    private var animationTime: Float

    public init(
        skeleton: KASkeleton,
        clips: [String: KAClip],
        playbackSpeed: Float = 1,
        defaultClip: String? = nil,
        defaultOffset: Float = 0,
        looping: Bool = true
    ) {
        self.defaultClip = defaultClip ?? clips.keys.sorted().first!
        self.defaultOffset = defaultOffset
        self.skeleton = skeleton
        self.clips = clips
        self.pose = skeleton.bindPose.clone()
        self.currentClipName = self.defaultClip
        self.animationTime = 0
        self.playbackSpeed = playbackSpeed
        self.looping = looping
        self.resetAnimation()
    }

    public func animate(_ deltaTime: Float) {
        if let clip = clips[currentClipName] {
            animationTime = clip.sample(
                pose: pose,
                inTime: animationTime + deltaTime * playbackSpeed,
                overrideClipLooping: looping)
        }
    }

    public func changeClip(
        clipName: String,
        startOffset: Float = 0,
        playbackSpeed: Float = 1,
        looping: Bool = true
    ) {
        self.currentClipName = clipName
        self.animationTime = startOffset
        self.playbackSpeed = playbackSpeed
        self.looping = looping
        animate(0)
    }

    public func currentClip() -> String {
        return currentClipName
    }

    public func resetAnimation() {
        changeClip(
            clipName: defaultClip,
            startOffset: defaultOffset,
            playbackSpeed: 1,
            looping: true)
    }
}
