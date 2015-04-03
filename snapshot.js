#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

captureLocalizedScreenshot('0-splash')

target.frontMostApp().mainWindow().buttons()["Next"].tap();
target.frontMostApp().mainWindow().buttons()["Authorize Location"].tap();

// target.frontMostApp().alert().buttons()["Allow"].tap();
target.frontMostApp().mainWindow().buttons()["Enable Notifications"].tap();

// target.frontMostApp().alert().buttons()["OK"].tap();
target.frontMostApp().mainWindow().buttons()["Authorize HealthKit"].tap();

captureLocalizedScreenshot('1-list')

target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.71, y:0.49}});

captureLocalizedScreenshot('2-edit')

target.frontMostApp().windows()[0].navigationBar().tapWithOptions({tapOffset:{x:0.90, y:0.47}});

// target.frontMostApp().alert().buttons()["OK"].tap();

target.frontMostApp().mainWindow().tableViews()[0].scrollViews()[0].elements()["Cortado"].staticTexts()["Double Shot (150 mg)"].tapWithOptions({tapOffset:{x:0.94, y:10.10}});
target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().rightButton().tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()["Cortado"].tap();

captureLocalizedScreenshot('3-edit')