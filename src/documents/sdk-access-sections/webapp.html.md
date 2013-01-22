---
doc: sdk-access
sectionId: webapp
sectionOrder: 2
---

# Web App (javascript)

First of all, be sure you have completed [Initial Requirements](#intro-initial-requirements) steps

As an exemple look at [https://sw.rec.la:2443/access/v0/demo.html](https://sw.rec.la:2443/v0/access/demo.html) Source code.

## Choices

### 1- Popup or returnURL ??
TODO

### 2- PrYv or custom signin Button
TODO

### 3- Custom handling of the signin process
TODO

## pryvAccess.setup(settings)

To use the sdk you need *pryv-access-sdk.js*  
For staging developpement you should use: `https://sw.rec.la:2443/access/v0/pryv-access-sdk.js`  
And add in your `<head></head>`  

For production use the pryv.io version 
	
	<script type="text/javascript" src="https://sw.pryv.io/access/v0/pryv-access-sdk.js"></script>

or to optimze page loading cloudfront cached version:

	<script type="text/javascript" src="//dlw0lofo79is5.cloudfront.net/sdk-access-webapp/v0/pryv-access-sdk.js"></script>
	
Then you can create you **settings** object with the following parameters: 

  - `requestingAppId` (string): Unique. Given by PrYv identifier for this app. It will be the key for the requested set of permission after user agreement.
  - `languageCode`(2 characters ISO 639-1 Code): Optional. If known the current language used by the user. This will influence the signin and register interface language.
  - `requestedPermissions` (object): The requested set of permissions to access user's channels & folders.
  - `returnURL` (string): Optional. If you don't want (or can't have) the popup signin-process and prefer set a returnURL. This URL will be called at the en of the SIGNIN process. This provides a better user experience on mobile devices.
  - `spanButtonID` (string) Optional. The id of a `<span />` element in the DOM of your web page. 
  - `callbacks` (functionS): called on each step of the sign-in process. Most of them are optional if you decided to rely on PrYv signin Button. All are optional excepted "accepted".
    - `initialization` (function()): When the initialization process is started. You may display a "loading" animation or for the user.
    - `needSignin` (function(popupUrl,pollUrl,pollRateMs)): Optional. Triggered when the user need to be redirected to PrYv Signin or register from. 
    	- param `popupUrl` (string): The URL to open in it's own window and to present to the user.
    	- param `pollUrl` (string): The URL to poll regularly in the background to grab the result of the sigin process.
    	- param `pollRateMs` (int): The minimum interval in milliseconds between to polling.
    - `accepted` (function(username,appToken)): **Mandatory**. Called when the signin process succeed and the permissions requested a granted.
    - `refused` (function(reason)): called when the user refuse to grant the requested permissions.
        - param `reason`(string): Technical information on how the user refused (not to be displayed).
    - `error` (function(pryvError)): called when an error interupting the signup process occured.
        - param `pryvError` (object): `{id: .., message: .., detail: ..}` 
        
## exemples 

### minimalistic

This app requests a contribute access to the *diary* channel. 
It relies on PrYv button and on a popup for signin. 


	<html>
	<head>
	<script type="text/javascript" src="//dlw0lofo79is5.cloudfront.net/sdk-access-webapp/v0/pryv-access-sdk.js"></script>
	</head>
	<body>
		<script>
		
		function callMeWithCredentials(username, appToken) {
			alert("SUCCESS! username:" + username + " appToken:" + appToken);
		}
		
		var requestedPermissions = [{"channelId" : "diary",
	                                     "level" : "contribute"}];
	    
	    pryvAccess.setup({
	        requestingAppId : 'Minimalistic Exemple For SDK Access',
	        requestedPermissions : requestedPermissions,
	        spanButtonID : 'pryvButton',
	        callbacks : callMeWithCredentials
	    });
	      
	    </script>
		<center><span id='pryvButton'></span></center>
	</body>
	</html>