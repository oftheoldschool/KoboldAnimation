import simd

struct CubicBezierFloat {
    let p1: Float
    let c1: Float
    let p2: Float
    let c2: Float
    
    func interpolate(t: Float) -> Float {
        let term1 = p1 * ((1 - t) * (1 - t) * (1 - t))
        let term2 = c1 * (3 * ((1 - t) * (1 - t)) * t)
        let term3 = c2 * (3 * (1 - t) * (t * t))
        let term4 = p2 * (t * t * t)
        return term1 + term2 + term3 + term4
    }
}

struct CubicHermiteFloat {
    let p1: Float
    let s1: Float
    let p2: Float
    let s2: Float
    
    func interpolate(t: Float) -> Float {
        let term1 = p1 * ((1 + 2 * t) * ((1 - t) * (1 - t)))
        let term2 = s1 * (t * ((1 - t) * (1 - t)))
        let term3 = p2 * ((t * t) * (3 - 2 * t))
        let term4 = s2 * ((t * t) * (t - 1))
        return term1 + term2 + term3 + term4
    }
}

struct CubicBezierFVec3 {
    let p1: SIMD3<Float>
    let c1: SIMD3<Float>
    let p2: SIMD3<Float>
    let c2: SIMD3<Float>
    
    func interpolate(t: Float) -> SIMD3<Float> {
        let term1 = p1 * ((1 - t) * (1 - t) * (1 - t))
        let term2 = c1 * (3 * ((1 - t) * (1 - t)) * t)
        let term3 = c2 * (3 * (1 - t) * (t * t))
        let term4 = p2 * (t * t * t)
        return term1 + term2 + term3 + term4
    }
}

struct CubicHermiteFVec3 {
    let p1: SIMD3<Float>
    let s1: SIMD3<Float>
    let p2: SIMD3<Float>
    let s2: SIMD3<Float>
    
    func interpolate(t: Float) -> SIMD3<Float> {
        let term1 = p1 * ((1 + 2 * t) * ((1 - t) * (1 - t)))
        let term2 = s1 * (t * ((1 - t) * (1 - t)))
        let term3 = p2 * ((t * t) * (3 - 2 * t))
        let term4 = s2 * ((t * t) * (t - 1))
        return term1 + term2 + term3 + term4
    }
}

struct CubicBezierFQuat {
    let p1: simd_quatf
    let c1: simd_quatf
    let p2: simd_quatf
    let c2: simd_quatf
    
    func interpolate(t: Float) -> simd_quatf {
        let term1 = p1 * ((1 - t) * (1 - t) * (1 - t))
        let term2 = c1 * (3 * ((1 - t) * (1 - t)) * t)
        let term3 = c2 * (3 * (1 - t) * (t * t))
        let term4 = p2 * (t * t * t)
        return term1 + term2 + term3 + term4
    }
}

struct CubicHermiteFQuat {
    let p1: simd_quatf
    let s1: simd_quatf
    let p2: simd_quatf
    let s2: simd_quatf
    
    func interpolate(t: Float) -> simd_quatf {
        let term1 = p1 * ((1 + 2 * t) * ((1 - t) * (1 - t)))
        let term2 = s1 * (t * ((1 - t) * (1 - t)))
        let term3 = p2 * ((t * t) * (3 - 2 * t))
        let term4 = s2 * ((t * t) * (t - 1))
        return term1 + term2 + term3 + term4
    }
}

