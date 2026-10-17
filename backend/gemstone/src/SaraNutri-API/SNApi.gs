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
	| patientSchema router |
	router := DocumentedRouter new.
	router spec
		title: 'SaraNutri API';
		version: SNApplication applicationVersion;
		description: 'SaraNutri application API.';
		server: 'http://localhost:8888' description: 'Development server'.
	patientSchema := OpenApiSchema object
		property: 'givenName' type: 'string';
		property: 'familyName' type: 'string';
		property: 'birthDate' schema: (OpenApiSchema string
			format: 'date';
			description: 'Optional ISO-8601 birth date.';
			yourself);
		required: #('givenName' 'familyName');
		yourself.
	router spec schema: 'Patient' definition: patientSchema.
	self registerHealthRouteOn: router.
	self registerPatientRoutesOn: router.
	^ router
%
category: 'routes'
classmethod: SNApi
registerHealthRouteOn: aRouter
	aRouter
		get: '/health'
		do: [ :request :response |
			self
				writeJson: (Dictionary new
					at: 'name' put: SNApplication applicationName;
					at: 'version' put: SNApplication applicationVersion;
					at: 'status' put: 'ok';
					yourself)
				status: 200
				to: response
		]
		operation: (OpenApiOperation new
			summary: 'Service health';
			description: 'Reports the availability and version of the SaraNutri API.';
			operationId: 'health';
			tag: 'system';
			response: 200 description: 'Service status';
			yourself).
%
category: 'routes'
classmethod: SNApi
registerPatientRoutesOn: aRouter
	| application |
	application := SNApplication current.
	self registerListPatientsRouteOn: aRouter application: application.
	self registerCreatePatientRouteOn: aRouter application: application
%
category: 'routes'
classmethod: SNApi
registerListPatientsRouteOn: aRouter application: anApplication
	aRouter
		get: '/patients'
		do: [ :request :response |
			self
				writeJson: (anApplication patients collect: [ :patient |
					self patientAsDictionary: patient ]) asArray
				status: 200
				to: response ]
		operation: (OpenApiOperation new
			summary: 'List patients';
			description: 'Returns all persisted patient profiles.';
			operationId: 'listPatients';
			tag: 'patients';
			response: 200
				description: 'Persisted patients'
				schema: (OpenApiSchema array: (OpenApiSchema ref: 'Patient'));
			yourself)
%
category: 'routes'
classmethod: SNApi
registerCreatePatientRouteOn: aRouter application: anApplication
	aRouter
		post: '/patients'
		do: [ :request :response |
			self
				createPatientFrom: request bodyContents
				in: anApplication
				respondOn: response ]
		operation: (OpenApiOperation new
			summary: 'Create patient';
			description: 'Creates and persists a patient profile.';
			operationId: 'createPatient';
			tag: 'patients';
			requestBodyJson: (OpenApiSchema ref: 'Patient');
			response: 201
				description: 'Created patient'
				schema: (OpenApiSchema ref: 'Patient');
			response: 400 description: 'Invalid patient data';
			response: 409 description: 'Persistence conflict';
			yourself)
%
category: 'request handling'
classmethod: SNApi
createPatientFrom: aJsonString in: anApplication respondOn: aResponse
	| patient |
	patient := [
		self patientFromDictionary: (JsonParser parse: aJsonString) ]
		on: Error
		do: [ :exception |
			System abortTransaction.
			^ self
				writeError: 'invalid_patient'
				message: exception messageText
				status: 400
				to: aResponse ].
	anApplication addPatient: patient.
	System commitTransaction ifFalse: [
		System abortTransaction.
		^ self
			writeError: 'persistence_conflict'
			message: 'The patient could not be committed'
			status: 409
			to: aResponse ].
	self
		writeJson: (self patientAsDictionary: patient)
		status: 201
		to: aResponse
%
category: 'serialization'
classmethod: SNApi
patientFromDictionary: aDictionary
	^ SNPatient
		named: (aDictionary at: 'givenName')
		familyName: (aDictionary at: 'familyName')
		birthDate: (self birthDateFromJsonValue: (
			aDictionary at: 'birthDate' ifAbsent: [ nil ]))
%
category: 'serialization'
classmethod: SNApi
patientAsDictionary: aPatient
	^ Dictionary new
		at: 'givenName' put: aPatient givenName;
		at: 'familyName' put: aPatient familyName;
		at: 'birthDate' put: (self birthDateAsJsonValue: aPatient birthDate);
		yourself
%
category: 'serialization'
classmethod: SNApi
birthDateFromJsonValue: aStringOrNil
	^ aStringOrNil
		ifNil: [ nil ]
		ifNotNil: [
			Date
				fromString: aStringOrNil
				usingFormat: #(3 2 1 $- 1 1) ]
%
category: 'serialization'
classmethod: SNApi
birthDateAsJsonValue: aDateOrNil
	^ aDateOrNil
		ifNil: [ nil ]
		ifNotNil: [
			aDateOrNil asStringUsingFormat: #(3 2 1 $- 1 1) ]
%
category: 'responses'
classmethod: SNApi
writeJson: anObject status: aStatusCode to: aResponse
	aResponse
		code: aStatusCode;
		accessControlAllowOrigin: '*';
		contentType: 'application/json; charset=UTF-8';
		content: anObject asJson
%
category: 'responses'
classmethod: SNApi
writeError: anErrorCode message: aMessage status: aStatusCode to: aResponse
	self
		writeJson: (Dictionary new
			at: 'error' put: anErrorCode;
			at: 'message' put: aMessage;
			yourself)
		status: aStatusCode
		to: aResponse
%
