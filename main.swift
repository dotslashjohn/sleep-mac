import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let menu = NSMenu()
    let toggleItem = NSMenuItem(title: "", action: #selector(toggle), keyEquivalent: "")

    func applicationDidFinishLaunching(_ n: Notification) {
        toggleItem.target = self
        menu.addItem(toggleItem)
        menu.addItem(.separator())
        let quit = NSMenuItem(title: "Quit Sleep Toggle", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quit)
        item.button?.target = self
        item.button?.action = #selector(clicked)
        item.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        refresh()
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in self?.refresh() }
    }

    // Left click toggles; right click (or ctrl-click) shows the menu.
    @objc func clicked() {
        let e = NSApp.currentEvent
        if e?.type == .rightMouseUp || e?.modifierFlags.contains(.control) == true {
            item.menu = menu
            item.button?.performClick(nil)
            item.menu = nil
        } else {
            toggle()
        }
    }

    func sleepDisabled() -> Bool {
        let out = run("/usr/bin/pmset", ["-g"]).output
        return out.split(separator: "\n").contains { line in
            let p = line.split(whereSeparator: { $0 == " " || $0 == "\t" })
            return p.count >= 2 && p[0] == "SleepDisabled" && p[1] == "1"
        }
    }

    func refresh() {
        let off = sleepDisabled()
        let symbol = off ? "cup.and.saucer.fill" : "moon.zzz"
        let img = NSImage(systemSymbolName: symbol, accessibilityDescription: off ? "Sleep off" : "Sleep on")
        img?.isTemplate = true
        item.button?.image = img
        item.button?.toolTip = off ? "Sleep is OFF (staying awake) – click to allow sleep"
                                   : "Sleep is ON (normal) – click to keep awake"
        toggleItem.title = off ? "Allow sleep again" : "Keep Mac awake"
    }

    @objc func toggle() {
        let newValue = sleepDisabled() ? "0" : "1"
        // Try passwordless sudo first (see sudoers rule), else ask for admin password.
        if run("/usr/bin/sudo", ["-n", "/usr/bin/pmset", "-a", "disablesleep", newValue]).status != 0 {
            let script = "do shell script \"/usr/bin/pmset -a disablesleep \(newValue)\" with administrator privileges"
            _ = run("/usr/bin/osascript", ["-e", script])
        }
        refresh()
    }

    @discardableResult
    func run(_ path: String, _ args: [String]) -> (status: Int32, output: String) {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: path)
        p.arguments = args
        let pipe = Pipe()
        p.standardOutput = pipe
        p.standardError = Pipe()
        do { try p.run() } catch { return (-1, "") }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        p.waitUntilExit()
        return (p.terminationStatus, String(decoding: data, as: UTF8.self))
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
