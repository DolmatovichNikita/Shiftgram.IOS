import TwilioVideo

class Settings: NSObject {
    
    let supportedAudioCodecs: [TVIAudioCodec] = [TVIIsacCodec(),
                                                 TVIOpusCodec(),
                                                 TVIPcmaCodec(),
                                                 TVIPcmuCodec(),
                                                 TVIG722Codec()]
    
    let supportedVideoCodecs: [TVIVideoCodec] = [TVIVp8Codec(),
                                                 TVIVp8Codec(simulcast: true),
                                                 TVIH264Codec(),
                                                 TVIVp9Codec()]
    
    var audioCodec: TVIAudioCodec?
    var videoCodec: TVIVideoCodec?
    
    var maxAudioBitrate = UInt()
    var maxVideoBitrate = UInt()
    
    func getEncodingParameters() -> TVIEncodingParameters?  {
        if maxAudioBitrate == 0 && maxVideoBitrate == 0 {
            return nil;
        } else {
            return TVIEncodingParameters(audioBitrate: maxAudioBitrate,
                                         videoBitrate: maxVideoBitrate)
        }
    }
    
    private override init() {
    }
    
    static let shared = Settings()
}
