import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("Application did finish launching")

        // Create the main window
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        if window == nil {
            print("Failed to create window")
            return
        }

        window.center()
        window.title = "PhoneBookApp"
        window.makeKeyAndOrderFront(nil)
        print("Window created and made key and order front")

        // Set the content view controller
        let contentView = NSHostingController(rootView: ContentView())
        if contentView == nil {
            print("Failed to create content view controller")
            return
        }
        window.contentViewController = contentView
        print("Content view controller set")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        print("Application will terminate")
    }
}
