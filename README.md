# Cortado

Cortado is an iPhone app to help you track your caffeine consumption habits. Besides letting you manually enter caffeine data, it detects when you are at a coffee shop and automatically prompts you to input data right from your lock screen or watch.

Cortado is available for sale on the [App Store](). While this codebase will allow you to build and run the app for free, if you use Cortado on a regular basis I'd ask you to please buy it to help support future development.


## Setup

1. Clone this repo: `git clone https://github.com/lazerwalker/cortado.git`
2. Generate API keys for both [Foursquare](https://developer.foursquare.com) and [Mixpanel](https://developer.foursquare.com).
3. If they are not already on your machine, install Cocoapods and Cocoapods-Keys: `sudo gem install cocoapods cocoapods-keys`
4. Run `pod install`, plugging in your Mixpanel and Foursquare API keys as prompted.
5. Open `Cortado.xcworkspace` in Xcode

From there, you should be good to go to build Cortado!


## Contributing	

Pull requests are welcome! Please run the test suite before opening a pull request, and please try to add new tests as appropriate.

Although there is no formal style guide, please follow the example of existing code. In general, you should:

* Prefer autolayout over manual frame positioning
* Prefer Interface Builder over layout code
* Have no more than 1-2 view controllers/views per Storyboard/xib.
* Maintain model immutability whenever possible
* Use MVVM architecture and ReactiveCocoa as appropriate


## License

The source code to Cortado is available under the MIT license. See the `LICENSE` file for more information.

The icons and photos that appear in this app are all licensed under a Creative Commons By-Attribution license. For licensing information and attribution for a given art asset, check out the "Image Attribution" section of the app (accessible from the settings page of the app itself, or from within `SettingsViewController.storyboard` in Xcode).

While it's not legally forbidden by the licensing terms, please do not simply submit your own version of Cortado to the App Store. Don't be a jerk.


## Contact

Mike Lazer-Walker

- https://github.com/lazerwalker
- [@lazerwalker](http://twitter.com/lazerwalker)
- http://lazerwalker.com
