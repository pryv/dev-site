---
doc: sdk-access
sectionId: webapp
sectionOrder: 2
---

# Web App (javascript)

First of all, be sure you have completed [Initial Requirements](#intro-initial-requirements) steps

As an exemple look at [https://sw.rec.la:2443/access/demo.html](https://sw.rec.la:2443/access/demo.html) Source code.

## Choices

*Note!!:* Prefered method for a better user experience is `auto`

### <a name="returnURL"></a> 1-  Popup or returnURL ?? 

During the authentication process, we need to open a PrYv access web page in a separate window. This is onde in order to secure personal user's information.   
This window can be opened in:

 - A popup, leaving the actual window open behind. This should be more comfortable on desktop browsers.
 - In place of the actual window, the user goes thru the process and come back to the URL you set at the end of the process.

#### * Popup 

If you want the authorization process to take place in a popup just set the `returnURL` settings to `false`.

#### * Self or Auto

If you want the authorization process to take place in the same windows, returning to this same exact url you can use `self[extra_params]<trailer>` or `auto[extra_params]<trailer>`.  

When the user returns to this same page, the pryv-access-sdk will parse `prYv` parameters.

* command  
  - **self**: Use the current page as returnURL value
  - **auto**: (prefered method) Use a returnURL when a mobile or tablet browser is detected and a popupOtherwise  
* parameters
  - **&lt;trailer>**: one of `?`, a `#` or a `&`
  - **[extra_parms]**: Use this space (uri_encoded) as a custom payload for the returning user. 

EXEMPLES

* with `https://mysite.com/page.php` as source URL.
  - **self#** -> `https://mysite.com/page.php#prYvkey=JDJKhadja&prYvstatus=...`
  - **self?** -> `https://mysite.com/page.php?prYvkey=JDJKhadja&prYvstatus=...`
  - **self?mycustom=A&** -> `https://mysite.com/page.php?mycustom=A&prYvkey=JDJKh...`
  - **auto?mobile=1&** (if mobile) -> `https://mysite.com/page.php?mobile=1&prYvkey=JD...`

* with `https://mysite.com/page.php?mycustom=1` as source URL.
  - **self&** -> `https://mysite.com/page.php?mycustom=1&prYvk...`

Make your own tests from the page:
[https://sw.rec.la:2443/access/test.html](https://sw.rec.la:2443/access/test.html)

#### * Custom 

Set the return URL to your own page such as 

	https://www.mysite.com/end-of-pryvAccess-process.php?
	
**Attention!!** The url submitted *must* end with a `?`, a `#` or a `&`  
Returned status will be appended to this URL.

**Exemples:**

ACCEPTED

		https://www.mysite.com/end-of-pryvAccess-process.php?
	prYvkey=GSbdasjgdv&prYvstatus=ACCEPTED&prYvusername=yacinthe&prYvtoken=VVhjDJDDG
	
REFUSED

		https://www.mysite.com/end-of-pryvAccess-process.php?
	prYvkey=GSbdasjgdv&prYvstatus=REFUSED&prYvmessage=refused+by+user
	
ERROR

		https://www.mysite.com/end-of-pryvAccess-process.php?
	prYvkey=GSbdasjgdv&prYvstatus=ERROR&prYvid=INTERNAL_ERROR&prYvmessage=...


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
  - `returnURL` (url or 'auto<extra>'): Optional. If you don't want (or can't have) the popup signin-process and prefer set a returnURL. This URL will be called at the en of the SIGNIN process.This provides a better user experience on mobile devices: see [Popup or returnURL](#returnURL)
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
	        returnURL: 'auto#',
	        spanButtonID : 'pryvButton',
	        callbacks : callMeWithCredentials
	    });
	      
	    </script>
		<center><span id='pryvButton'></span></center>
	</body>
	</html>