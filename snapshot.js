#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

captureLocalizedScreenshot('0-splash')

target.frontMostApp().mainWindow().buttons()["Next"].tap();
target.frontMostApp().mainWindow().buttons()["Authorize Location"].tap();
target.frontMostApp().mainWindow().buttons()["Enable Notifications"].tap();
target.frontMostApp().mainWindow().buttons()["Authorize HealthKit"].tap();

captureLocalizedScreenshot('1-list')
target.delay(1.0)
target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.5, y:0.5}});

target.delay(4.0)
captureLocalizedScreenshot('2-edit')
target.frontMostApp().navigationBar().leftButton().tap();

target.frontMostApp().mainWindow().tableViews()[0].scrollViews()[0].elements()["Cortado"].tap();

captureLocalizedScreenshot('3-drink')