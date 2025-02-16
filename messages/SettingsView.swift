//
//  SettingsView.swift
//  Radio Messager
//
//  Created by Andrew Morrison on 2/15/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("callsign") private var callsign: String = ""
    @AppStorage("rate") private var rate: Double = 10.0
    @AppStorage("tone") private var tone: Double = 600.0
    
    var body: some View {
        Form {
            Section(header: Text("Callsign")) {
                TextField("Enter your callsign", text: $callsign)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("A valid callsign is required to transmit.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Section(header: Text("Rate")) {
                Slider(value: $rate, in: 4...60, step: 0.1)
                HStack {
                    Text("4 WPM")
                    Spacer()
                    Text(String(format: "%.1f WPM", rate))
                    Spacer()
                    Text("60 WPM")
                }
                .font(.caption)
            }
            
            Section(header: Text("Tone")) {
                Slider(value: $tone, in: 300...1000, step: 1)
                HStack {
                    Text("300 Hz")
                    Spacer()
                    Text(String(format: "%0.f Hz", tone))
                    Spacer()
                    Text("1000 Hz")
                }
                .font(.caption)
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
