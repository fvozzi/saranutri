! ------- Create dictionary if it is not present
run
| dictionaryName names userProfile |
dictionaryName := #'SaraNutri'.
userProfile := System myUserProfile.
names := userProfile symbolList names.
(names includes: dictionaryName) ifFalse: [
	| symbolDictionary |
	symbolDictionary := SymbolDictionary new name: dictionaryName; yourself.
	userProfile insertDictionary: symbolDictionary at: names size + 1.
].
%
set compile_env: 0
! ------------------- Class definition for SNApi
expectvalue /Class
doit
Object subclass: 'SNApi'
  instVarNames: #()
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: SaraNutri
  options: #()
%
expectvalue /Class
doit
SNApi category: 'SaraNutri-API'
%
! ------------------- Class methods for SNApi
category: 'launching'
classmethod: SNApi
runHttp
	^ self runHttpOnPort: 8888
%
category: 'launching'
classmethod: SNApi
runHttpOnPort: anInteger
	HttpListener new
		listenBacklog: 200;
		port: anInteger;
		server: HttpServer;
		router: self defaultRouter;
		run
%
category: 'routes'
classmethod: SNApi
defaultRouter
	| router |
	router := DocumentedRouter new.
	router spec
		title: 'SaraNutri API';
		version: SNApplication applicationVersion;
		description: 'SaraNutri application API.';
		server: 'http://localhost:8888' description: 'Development server'.
	self registerHealthRouteOn: router.
	^ router
%
category: 'routes'
classmethod: SNApi
registerHealthRouteOn: aRouter
	aRouter
		get: '/health'
		do: [ :request :response |
			response
				content: (Dictionary new
					at: 'name' put: SNApplication applicationName;
					at: 'version' put: SNApplication applicationVersion;
					at: 'status' put: 'ok';
					yourself) asJson;
				contentType: 'application/json; charset=UTF-8'.
		]
		operation: (OpenApiOperation new
			summary: 'Service health';
			description: 'Reports the availability and version of the SaraNutri API.';
			operationId: 'health';
			tag: 'system';
			response: 200 description: 'Service status';
			yourself).
%
