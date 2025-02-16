import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isMe: Bool
    let timestamp: String
    let snr: Int
    var isTransmitting: Bool
}

struct ChatView: View {
    @State private var messages: [Message] = [
        Message(text: "W2ASM CQ", isMe: false, timestamp: "10:00 AM", snr: 25, isTransmitting: false),
    ]
    @State private var newMessage: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var showTimestamps: Bool = false
    
    @AppStorage("rate") private var rate: Double = 10.0
    @AppStorage("tone") private var tone: Double = 700.0
    
    let transmitter = MorseTransmitter()
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(messages) { message in
                            MessageBubble(message: message, showTimestamp: showTimestamps)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: messages.count) { _, _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            .onTapGesture {
                withAnimation {
                    showTimestamps.toggle()
                }
            }
            Divider()
            HStack {
                TextField("Message...", text: $newMessage, onCommit: sendMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isTextFieldFocused)
                    .onChange(of: newMessage) { newValue in
                        newMessage = newValue.uppercased().filter { "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.,?- " .contains($0) }
                    }
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
                .disabled(newMessage.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
    }
    
    private func sendMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let message = Message(
            text: newMessage,
            isMe: true,
            timestamp: "\(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short))",
            snr: Int.random(in: 10...40),
            isTransmitting: true
        )
        messages.append(message)
        newMessage = ""
        
        DispatchQueue.global(qos: .background).async {
            transmitter.transmit(message: message.text, wpm: rate, tone: tone)
            DispatchQueue.main.async {
                if let index = messages.firstIndex(where: { $0.id == message.id }) {
                    messages[index].isTransmitting = false
                }
            }
        }
    }
}

struct MessageBubble: View {
    let message: Message
    let showTimestamp: Bool
    
    var body: some View {
        HStack {
            if message.isMe { Spacer() }
            VStack(alignment: message.isMe ? .trailing : .leading) {
                HStack(spacing: 0) {
                    let words = message.text.split(separator: " ", omittingEmptySubsequences: false)
                    ForEach(Array(words.enumerated()), id: \..offset) { index, word in
                        if let match = word.range(of: "[A-Z]{1,2}[0-9][A-Z]{2,3}", options: .regularExpression) {
                            let callsign = String(word[match])
                            Link(callsign, destination: URL(string: "https://www.qrz.com/db/\(callsign)")!)
                        } else {
                            Text(word)
                        }
                        if index < words.count - 1 {
                            Text(" ")
                        }
                    }
                }
                .padding()
                .background(message.isMe ? (message.isTransmitting ? Color.orange : Color.blue) : Color.gray.opacity(0.2))
                .foregroundColor(message.isMe ? .white : .black)
                .cornerRadius(15)
                .frame(maxWidth: 250, alignment: message.isMe ? .trailing : .leading)
                if showTimestamp {
                    HStack {
                        Text(message.timestamp)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("SNR: \(message.snr) dB")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            if !message.isMe { Spacer() }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
