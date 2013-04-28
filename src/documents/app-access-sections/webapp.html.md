---
doc: app-access
sectionId: web-app
sectionOrder: 2
---

# Web app (Javascript)

Obtaining an access token for your web app.

## What you need

* make sure you got the [initial requirements](#intro-initial-requirements) ready.
* include the following script in your page:
	- Staging version (recommended at the moment):  
	```html
	<script type="text/javascript" src="https://sw.rec.la:2443/access/v1/pryv-sdk.js"></script>
	```
	- Production version:
	```html
	<script type="text/javascript" src="https://sw.pryv.me/access/v1/pryv-sdk.js"></script>
	```
	- or the optimized CloudFront cache:
	```html
	<script type="text/javascript" src="//d3gblc8a9weyfb.cloudfront.net/access/v1/pryv-sdk.js"></script>
	```
* construct a `settings` JSON object
* call `Pryv.Access.setup(settings)`

For a more fleshed-out example look at the source code of [https://sw.rec.la/access/demo.html](https://sw.rec.la:2443/access/demo.html).

<a name="webapp.test"></a>Or make your own tests from the page:
[https://sw.rec.la:2443/access/test.html](https://sw.rec.la:2443/access/test.html)


### Example: Minimalistic

This app requests a "contribute" access to the "diary" channel, using the PrYv button and a popup for sign-in.

**TODO: review this code**

```html

	<!DOCTYPE html>
	<html>
	<head>
	<title>Minimalistic example</title>
	<script type="text/javascript" src="//d3gblc8a9weyfb.cloudfront.net/access/v1/pryv-sdk.js"></script>
	</head>
	<body>
		<script type="text/javascript">
	
		function callMeWithCredentials(username, appToken, languageCode) {
			alert("SUCCESS! username:" + username + " appToken:" + 
					appToken + " language:" + languageCode);
		}
	
		var requestedPermissions = [{"channelId" : "diary",
									"defaultName" : "Diary", // this name is localized
	                                     "level" : "contribute"}];
	
	    Pryv.Access.setup({
	        requestingAppId : 'pryv-mini-example',
	        requestedPermissions : requestedPermissions,
	        returnURL: 'auto#',
	        spanButtonID : 'pryvButton',
	        callbacks : {
              initialization : function() { },
              needSignin : function(popupUrl, pollUrl, pollRateMs) { },
              accepted : function(username, appToken, languageCode) {
                console.log("** SUCCESS! username:" + username + 
                            " appToken:" + appToken + 
                            " lang:" + languageCode);
              },
              refused: function(reason) {
                 console.log("** REFUSED! " + reason);
              },
              error: function(code, message) {
                console.log("** ERROR! " + code + " " + message);
           }
	    });
	
	    </script>
		<span id='pryvButton'></span>
	</body>
	</html>
```

## Pryv.Access.setup(settings)


The **settings** object supports the following parameters:

  - `requestingAppId` (string): Unique. Given by PrYv identifier for this app. It will be the key for the requested set of permission after user agreement.
  - `languageCode`(2 characters ISO 639-1 Code): Optional. If known the current language used by the user. This will influence the signin and register interface language.
  - `requestedPermissions` (object): The requested set of permissions to access user's channels & folders.
  - `returnURL` (url or 'auto<extra>'): Optional. If you don't want (or can't have) the popup signin-process and prefer set a returnURL. This URL will be called at the en of the SIGNIN process.This provides a better user experience on mobile devices. Details: [settings.returnURL](#webapp.returnURL)
  - `spanButtonID` (string) Optional. The id of a `<span />` element in the DOM of your web page. Details: [settings.spanButtonID](#webapp.spanButtonID)
  - `callbacks` (functionS): called on each step of the sign-in process. Most of them are optional if you decided to rely on PrYv signin Button. All are optional excepted "accepted". Details: [settings.callbacks](#webapp.callbacks)
    - `initialization` (function()): When the initialization process is started. You may display a "loading" animation or for the user.
    - `needSignin` (function(popupUrl,pollUrl,pollRateMs)): Optional. Triggered when the user need to be redirected to PrYv Signin or register from.
    	- param `popupUrl` (string): The URL to open in it's own window and to present to the user.
    	- param `pollUrl` (string): The URL to poll regularly in the background to grab the result of the sigin process.
    	- param `pollRateMs` (int): The minimum interval in milliseconds between to polling.
    - `accepted` (function(username,appToken,languageCode)): **Mandatory**. Called when the signin process succeed and the permissions requested a granted. It's also triggered after a logout action with `(false,false,false)` as parameters.
    - `refused` (function(reason)): called when the user refuse to grant the requested permissions.
        - param `reason`(string): Technical information on how the user refused (not to be displayed).
    - `error` (function(pryvError)): called when an error interupting the signup process occured.
        - param `pryvError` (object): `{id: .., message: .., detail: ..}`



### <a name="webapp.returnURL"></a> settings.returnURL : Popup or URL Callback


During the authentication process, we need to open a PrYv access web page in a separate window. This is in order to secure personal user's information.  

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

EXAMPLES

* with `https://mysite.com/page.php` as source URL.
  - **self#** -> `https://mysite.com/page.php#prYvkey=JDJKhadja&prYvstatus=...`
  - **self?** -> `https://mysite.com/page.php?prYvkey=JDJKhadja&prYvstatus=...`
  - **self?mycustom=A&** -> `https://mysite.com/page.php?mycustom=A&prYvkey=JDJKh...`
  - **auto?mobile=1&** (if mobile) -> `https://mysite.com/page.php?mobile=1&prYvkey=JD...`

* with `https://mysite.com/page.php?mycustom=1` as source URL.
  - **self&** -> `https://mysite.com/page.php?mycustom=1&prYvk...`

Make your own tests from the [test page](webapp.test).

#### * Custom

Set the return URL to your own page such as

	https://www.mysite.com/end-of-Pryv.Access-process.php?

**Attention!!** The url submitted *must* end with a `?`, a `#` or a `&`
Returned status will be appended to this URL.

#### Examples of return URL

ACCEPTED

		https://www.mysite.com/end-of-Pryv.Access-process.php?
	prYvkey=GSbdasjgdv&prYvstatus=ACCEPTED&prYvusername=yacinthe&prYvtoken=VVhjDJDDG

REFUSED

		https://www.mysite.com/end-of-Pryv.Access-process.php?
	prYvkey=GSbdasjgdv&prYvstatus=REFUSED&prYvmessage=refused+by+user

ERROR

		https://www.mysite.com/end-of-Pryv.Access-process.php?
	prYvkey=GSbdasjgdv&prYvstatus=ERROR&prYvid=INTERNAL_ERROR&prYvmessage=...

### <a name="webapp.spanButtonID"></a> settings.spanButtonID : Rely on PrYv standard Button
TODO

### <a name="webapp.callbacks"></a> settings.callbacks Custom handling of the signin process
TODO

## Pryv.Access.popupLogin()
Once setup is done, you can trigger the populLogin window from your own button.  
Note: Trigger it from a user-click event.

## Pryv.Access.logout()
Once setup is done, and user logged in. Erase current credential and restart setup with the same settings.

**logout()** will trigger a `settings.callbacks.success(false,false,false);`

## Pryv.Access.retry()
If a user refused to grant access, restart the setup process with the same settings. 

## Other Examples


### Full


