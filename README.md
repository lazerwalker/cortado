# Cortado

Cortado is an iPhone app to help you track your caffeine consumption habits. Besides letting you manually enter caffeine data, it detects when you are at a coffee shop and automatically prompts you to input data right from your lock screen or watch.

For more information on the ideas behind Cortado, check out the [blog post](http://blog.lazerwalker.com/2015/06/25/location-as-intent-introducing-cortado.html) introducing it.

Cortado is available for sale on the [App Store](https://itunes.apple.com/us/app/cortado/id969899327). While this codebase will allow you to build and run the app for free, if you actually use Cortado, please buy it on the App Store to help support future development.


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


## A Plea

Releasing Cortado under such a liberal license is an experiment. I'm putting a lot of trust in you. Please don't abuse that trust. If you use Cortado, please buy a copy rather than simply compiling it from source. If you want to build your own software based off of my code, please make it meaningfully different rather than just a Cortado clone. You're all wonderful people, and I know I don't even need to be saying any of this.


## License

The source code to Cortado is available under the MIT license. See the `LICENSE` file for more information.

The icons and photos that appear in this app are all licensed under a Creative Commons By-Attribution license. For licensing information and attribution for a given art asset, check out the "Image Attribution" section of the app (accessible from the settings page of the app itself, or from within `SettingsViewController.storyboard` in Xcode).

Although technically allowed by the licensing terms, please do not simply submit your own version of Cortado to the App Store.


## Contact

Mike Lazer-Walker

- https://github.com/lazerwalker
- [@lazerwalker](http://twitter.com/lazerwalker)
- http://lazerwalker.com
