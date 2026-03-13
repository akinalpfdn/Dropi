import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @State private var isRecordingHotkey = false

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0.3)
            settingsList
        }
        .frame(width: Constants.Shelf.compactWidth)
    }

    private var header: some View {
        HStack {
            Button {
                NotificationCenter.default.post(name: .closeSettings, object: nil)
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.system(size: 16))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            Text("Settings")
                .font(.system(size: 14, weight: .semibold))

            Spacer()
        }
        .padding(.horizontal, Constants.Shelf.padding)
        .padding(.vertical, 10)
    }

    private var settingsList: some View {
        ScrollView {
            VStack(spacing: 16) {
                triggersSection
                hotkeySection
                generalSection
            }
            .padding(Constants.Shelf.padding)
        }
    }

    // MARK: - Triggers

    private var triggersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Triggers")

            settingsToggle("Hotkey", icon: "keyboard", isOn: $settings.hotkeyEnabled)
            settingsToggle("Shake while dragging", icon: "hand.draw", isOn: $settings.shakeEnabled)
            settingsToggle("Move to screen edge", icon: "rectangle.righthalf.inset.filled.arrow.right", isOn: $settings.edgeEnabled)
        }
    }

    // MARK: - Hotkey

    private var hotkeySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Hotkey")

            HStack {
                Text("Shortcut")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    isRecordingHotkey.toggle()
                } label: {
                    Text(isRecordingHotkey ? "Press keys..." : settings.hotkeyDisplayString)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isRecordingHotkey ? Color.accentColor.opacity(0.2) : Color.white.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(isRecordingHotkey ? Color.accentColor.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .background(
                HotkeyRecorder(isRecording: $isRecordingHotkey) { keyCode, modifiers in
                    settings.updateHotkey(keyCode: keyCode, modifiers: modifiers)
                }
            )
        }
    }

    // MARK: - General

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("General")

            settingsToggle("Show menu bar icon", icon: "menubar.rectangle", isOn: $settings.showMenuBarIcon)
            settingsToggle("Launch at login", icon: "power", isOn: $settings.launchAtLogin)
        }
    }

    // MARK: - Helpers

    private func sectionLabel(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.tertiary)
            .tracking(0.5)
    }

    private func settingsToggle(_ title: String, icon: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(width: 20)

            Text(title)
                .font(.system(size: 12))

            Spacer()

            Toggle("", isOn: isOn)
                .toggleStyle(.switch)
                .scaleEffect(0.7)
                .frame(width: 40)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}

// MARK: - Hotkey Recorder

struct HotkeyRecorder: NSViewRepresentable {
    @Binding var isRecording: Bool
    let onRecord: (UInt16, NSEvent.ModifierFlags) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = HotkeyRecorderView()
        view.onRecord = { [self] keyCode, modifiers in
            onRecord(keyCode, modifiers)
            isRecording = false
        }
        context.coordinator.view = view
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let view = context.coordinator.view {
            if isRecording {
                view.startRecording()
            } else {
                view.stopRecording()
            }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator {
        var view: HotkeyRecorderView?
    }
}

class HotkeyRecorderView: NSView {
    var onRecord: ((UInt16, NSEvent.ModifierFlags) -> Void)?
    private var monitor: Any?

    func startRecording() {
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            guard !modifiers.isEmpty else { return event }
            self?.onRecord?(event.keyCode, modifiers)
            self?.stopRecording()
            return nil
        }
    }

    func stopRecording() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
    }
}

// MARK: - Notification

extension Notification.Name {
    static let closeSettings = Notification.Name("closeSettings")
}
