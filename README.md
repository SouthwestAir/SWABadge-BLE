# 📛 SWABadge

[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) 

[![Sketch](https://img.shields.io/badge/Sketch-FFB387?style=for-the-badge&logo=sketch&logoColor=black)](https://sketch.com)
[![Xcode](https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white)](https://developer.apple.com)
[![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://developer.apple.com)
[![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)](https://developer.apple.com)

#### Custom BLE circuit, 3d printed case and button, and sample iOS code

## 💡 Concept

Creation of a wearable Bluetooth "badge" to receive urgent notifications, and respond immediately via a tap.

## 📜 Background

During our recent prototype testing in the lobby, we rolled out a feature enabling our Customer Service Agents (CSAs) to access tools via their mobile devices. We noticed that, especially during interactions with passengers, their iPads would accumulate numerous notifications.

We designed and built a Bluetooth button that vibrates for essential notifications, such as a passenger requiring assistance. With a simple press, CSAs can acknowledge and signal their response, effectively communicating, "Yes, I'm on it!" Leveraging our 3D printing capabilities and existing IoT expertise, we crafted a BLE circuit for this solution.

Our four-step build process was:

1. Build the BLE circuit
2. Integrate into the [chat code](https://github.com/SouthwestAir/SWAChat)
3. 3d print a case
4. Assemble and test!

### Integration into the chat code

We used the chat code from our previous open source project [`SWAChat`](https://github.com/SouthwestAir/SWAChat):

- [https://github.com/SouthwestAir/SWAChat](https://github.com/SouthwestAir/SWAChat)

After following the instructions (setting up and connecting to a Firebase instance) we will have a basis for adding our Bluetooth connectivity.

The first thing we need to do is modify the Info.plist to ask permission to use Bluetooth.

You can do this one of two ways:

a) In your Info.plist, add the row for "Privacy - Bluetooth Always Usage Description", and add a string that is something like "This app requires the use of Bluetooth to connect to our cool comm badge."

b) If you prefer to modify the plist via the "Open as source code" method, add this inside the parent `<dict></dict>` fields:

```
	<key>NSBluetoothAlwaysUsageDescription</key>
	<string>This app requires the use of Bluetooth to connect to our cool comm badge.</string>
```

Then you can copy or add a new file "NewToothManager.swift" found in this repository (in the `02-Chat-code` folder). That file connects and manages the comm device.

(This was built with the assumption that only one comm device will be used at a time, to make this simpler to implement. There are only two basic features for this device, although that could be enhanced as well.)

To integrate this feature into a ViewController, there are two features to implement.

The first is to notify a user when something requires their attention. The badge will vibrate when this message is successfully sent:

```
  // BLE Message sent to SWABadge device if available
  NewToothManager.shared.sendBuzz(msg: "notify user")
```

*<span style="color:red">(If using the ChatDemo, this can be added to the `reloadCurrentChatMessages` method of the `ChatViewController-Messages.swift` file, within the `if channel == currentChatRoom` code block.</span>)*

The second feature is to accept a response from the wearer. We do this by subscribing to an in-app notification, via the NotificationCenter singleton:

```
  NotificationCenter.default.addObserver(
    self,
    selector: #selector(self.swaBadgeTapped(_:)),
    name: Notification.Name.swaBadgeTapped,
    object: nil
  )
```

And we will need to do something with that message, like the following:

```
  @objc func swaBadgeTapped(_ notification: Notification) {
    // do something when the badge button is tapped

  }
```

*<span style="color:red">(If using the ChatDemo, this can be added to the `ChatViewController-Form.swift` file. Add the notification in `setupForm()`, paste the `swaBadgeTapped` method in the file, and replace the `TODO` with something like `sendMessage(self, message: "On it! (sent via SWABadge)")`.</span>)*

Then build and test, to make sure this feature is working with the circuit.


## 🚀 Future ideas

We had a number of enhancements that we've come up with, using this badge as a base. For example, we were thinking about adding a speaker and microphone to allow the wearer to hear a message (i.e. "help needed at gate C15", respond with their voice, and then use speech-to-text on their phone to submit it as a chat message). This would be complicated by having to send audio via a bytestream through Bluetooth.


## 💻 Contributors

The following members of Technology Innovation contributed to this project:

| ![Jeffrey Berthiaume](screenshots/avatar_jeffrey_berthiaume.png) |
| :---: | 
| Jeffrey Berthiaume  |
| [![@jeffreality](https://raster.shields.io/badge/twitter-%40jeffreality-blue?logo=twitter&style=for-the-badge)](https://twitter.com/jeffreality) |
| [![jeffreality](https://raster.shields.io/badge/linkedin-%40jeffreality-lightblue?logo=linkedin&style=for-the-badge)](https://linkedin.com/in/jeffreality) |
| [![jeffrey-berthiaume](https://img.shields.io/badge/Stack_Overflow-FE7A16?style=for-the-badge&logo=stack-overflow&logoColor=white)](https://stackoverflow.com/users/71607/jeffrey-berthiaume) |

| ![Brady Trexler](screenshots/avatar_brady_trexler.png) |
| :---: | 
| E. Brady Trexler, PhD  |
| [![bradytrexler](https://raster.shields.io/badge/linkedin-%40bradytrexler-lightblue?logo=linkedin&style=for-the-badge)](https://linkedin.com/in/bradytrexler) |


## 📖 Citations

Reference to cite if needed:

```
@software {
	title = {SWA Badge},
	author = {Technology Innovation},
	affiliation = {Southwest Airlines},
	url = {https://github.com/SouthwestAir/SWABadge},
	month = {09},
	year = {2023},
	license: {BSD-3-Clause}
	version: {1.0}
}

```
