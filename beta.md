# Welcome to Cortado!

Cortado is an app to help you track your caffeine intake. 

The big-picture idea is that you shouldn't need to remember to open the app and futz around every time you have a coffee or a tea. Instead, every time you're at a coffee shop, it sends you a notification to remind you.

It's still pretty rough, and doesn't have any sort of onboarding process yet, so here's some info to help you figure out what the heck it is.


## Onboarding

On initial load, the app currently asks to enable push notifications, location services, and HealthKit read/write access to caffeine data. You need to enable all of these.


## Usage

When you first get into the app, tap the 'no drink selected' button and choose the drink that you usually order when you go to a coffee shop.

The next time you're at any coffee shop, you should get a push notification from Cortado. If you swipe it to see the interactive notification options (swipe left from the lock screen / notification center, or down if it's showing at the top of the screen), you wlil have the option to immediately add your preferred drink to HealthKit, or open the app to select a different drink. 

The caffeine entry will be stored in HealthKit, with lots of metadata (drink info, venue name, GPS coordinates, etc). The time will be set to when the notification arrived, not when you dealt with it, so there's no rush. You can edit entries either from the Health app or from within Cortado.

You can also manually add drinks to HealthKit by tapping the plus button from within the app.


## Feedback

My email address is michael@lazerwalker.com. Let me know what you think!


## Tracking

I feel deeply uncomfortable sending data to a third party analytics service when handling something as sensitive as your personal data. That being said, for the sake of this beta, I *am* using an analytics service (Mixpanel). This will not be present in the final release. I am not storing your GPS location data, and the data I store is in no way able to be tied back to you or any other specific individual (you'll notice the app doesn't ask you to authenticate with Facebook/Twitter/email/etc).