platform :ios, '8.0'

target 'Cortado' do
    pod 'ARAnalytics/Mixpanel', :git => 'https://github.com/orta/ARAnalytics.git'
    pod "Asterism", "~> 1.0.0"
    pod 'FLKAutoLayout', '~> 0.2'
    pod 'FXForms', '~> 1.2'
    pod 'IntentKit/Mail'
    pod 'iRate'
    pod "Mantle", "~> 1.5"
    pod 'MBProgressHUD', '~> 0.9'
    pod 'ReactiveCocoa', '~> 2.5'
    pod 'ReactiveViewModel', '~> 0.2'
    pod 'VTAcknowledgementsViewController'
    pod 'YLGIFImage'
end

target 'CortadoTests' do
    pod 'Expecta+Snapshots'
    pod 'Specta'
    pod 'Expecta'
    pod 'OCMock'
end

plugin 'cocoapods-keys', {
    :project => "Cortado",
    :keys => [
        "foursquareClientID",
        "foursquareClientSecret",
        "mixpanelToken"
    ]
}
