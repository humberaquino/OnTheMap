# On the Map
This is a iOS 8 project submition for Udacity's 'Intro to iOS App Development with Swift'


## Important
This project uses Swift 1.2 and iOS 8.3. Also, it uses [Facebook SKD 4.0.1][1] and for this reason it need the SDK installed at *~/Documents/FacebookSDK/*

However, to be able to compile it you have to remove the module maps manually from each of the FBSDK*Kit.framework bundles; e.g., `rm -r ~/Documents/FacebookSDK/FBSDKCoreKit.framework/Modules/` (and repeat for FBSDKLoginKit and FBSDKShareKit. [More info] [2]

## Notes

Trying to use cocoapods with Facebook SDK 4.0.1 didn't work. 

    cocoapods (0.36.3)
    Facebook-iOS-SDK (4.0.1)

Error:
    
    '../FBSDKMath.h' file not found


It should be solved in the current dev branch and is planned to be part of version 4.1.

More info in issue [725][3]

### References

[1]: http://www.brianjcoleman.com/tutorial-how-to-use-login-in-facebook-sdk-4-0-for-swift/

[2]: https://developers.facebook.com/bugs/362995353893156/

[3]: https://github.com/facebook/facebook-ios-sdk/issues/725
