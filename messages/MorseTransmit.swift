import AVFoundation
import Foundation
import Combine

class MorseTransmitter {
    private var audioEngine = AVAudioEngine()
    private var tonePlayer = AVAudioPlayerNode()
    private var sampleRate: Double = 44100.0
    private var bufferSize: AVAudioFrameCount = 44100
    private var transmissionCancellable: AnyCancellable?
    private let transmissionQueue = DispatchQueue(label: "MorseTransmissionQueue")
    private var isTransmitting = false
    
    private let morseCode: [Character: String] = [
        "A": ".-",    "B": "-...",  "C": "-.-.",  "D": "-..",
        "E": ".",     "F": "..-.",  "G": "--.",   "H": "....",
        "I": "..",    "J": ".---",  "K": "-.-",   "L": ".-..",
        "M": "--",    "N": "-.",    "O": "---",   "P": ".--.",
        "Q": "--.-",  "R": ".-.",   "S": "...",   "T": "-",
        "U": "..-",   "V": "...-",  "W": ".--",   "X": "-..-",
        "Y": "-.--",  "Z": "--..",  "1": ".----", "2": "..---",
        "3": "...--", "4": "....-", "5": ".....", "6": "-....",
        "7": "--...", "8": "---..", "9": "----.", "0": "-----",
        " ": " "
    ]
    
    func transmit(message: String, wpm: Double, tone: Double) -> Future<Void, Never> {
        return Future { promise in
            self.transmissionQueue.async {
                guard !self.isTransmitting else {
                    promise(.success(()))
                    return
                }
                self.isTransmitting = true
                
                let morseMessage = message.uppercased().compactMap { self.morseCode[$0] }.joined(separator: " ")
                self.playMorse(morseMessage, wpm: wpm, tone: tone) {
                    self.isTransmitting = false
                    promise(.success(()))
                }
            }
        }
    }
    
    func stop() {
        isTransmitting = false
        audioEngine.stop()
        tonePlayer.stop()
    }
    
    private func playMorse(_ morse: String, wpm: Double, tone: Double, completion: @escaping () -> Void) {
        let dotDuration = 1.2 / wpm
        let dashDuration = dotDuration * 3
        let spaceDuration = dotDuration
        let letterSpaceDuration = dotDuration * 3
        let wordSpaceDuration = dotDuration * 7
        
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        audioEngine.attach(tonePlayer)
        audioEngine.connect(tonePlayer, to: audioEngine.mainMixerNode, format: format)
        
        do {
            try audioEngine.start()
            for char in morse {
                guard isTransmitting else { completion(); return }
                switch char {
                case ".": playTone(frequency: tone, duration: dotDuration)
                case "-": playTone(frequency: tone, duration: dashDuration)
                case " ": usleep(useconds_t(wordSpaceDuration * 1_000_000))
                default: usleep(useconds_t(letterSpaceDuration * 1_000_000))
                }
                usleep(useconds_t(spaceDuration * 1_000_000))
            }
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
        completion()
    }
    
    private func playTone(frequency: Double, duration: Double) {
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let buffer = AVAudioPCMBuffer(pcmFormat: tonePlayer.outputFormat(forBus: 0), frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        let channels = buffer.floatChannelData![0]
        
        for i in 0..<Int(frameCount) {
            let sample = sin(2.0 * .pi * frequency * Double(i) / sampleRate)
            channels[i] = Float(sample)
        }
        
        tonePlayer.scheduleBuffer(buffer, completionHandler: nil)
        tonePlayer.play()
        usleep(useconds_t(duration * 1_000_000))
    }
}
