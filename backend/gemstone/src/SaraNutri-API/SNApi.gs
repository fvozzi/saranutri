set compile_env: 0
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
	| appointmentSchema patientSchema router sessionSchema userSchema |
	router := DocumentedRouter new.
	router spec
		title: 'SaraNutri API';
		version: SNApplication applicationVersion;
		description: 'SaraNutri application API.';
		server: 'http://localhost:8888' description: 'Development server'.
	patientSchema := OpenApiSchema object
		property: 'id' type: 'string';
		property: 'givenName' type: 'string';
		property: 'familyName' type: 'string';
		property: 'birthDate' schema: (OpenApiSchema string
			format: 'date';
			description: 'Optional ISO-8601 birth date.';
			yourself);
		required: #('givenName' 'familyName');
		yourself.
	userSchema := OpenApiSchema object
		property: 'email' type: 'string';
		property: 'displayName' type: 'string';
		property: 'role' type: 'string';
		required: #('email' 'displayName' 'role');
		yourself.
	sessionSchema := OpenApiSchema object
		property: 'accessToken' type: 'string';
		property: 'user' schema: (OpenApiSchema ref: 'User');
		required: #('accessToken' 'user');
		yourself.
	appointmentSchema := OpenApiSchema object
		property: 'id' type: 'string';
		property: 'patient' schema: (OpenApiSchema ref: 'Patient');
		property: 'scheduledAt' schema: (OpenApiSchema string
			format: 'date-time';
			yourself);
		property: 'status' type: 'string';
		required: #('id' 'patient' 'scheduledAt' 'status');
		yourself.
	router spec
		schema: 'Patient' definition: patientSchema;
		schema: 'User' definition: userSchema;
		schema: 'Session' definition: sessionSchema;
		schema: 'Appointment' definition: appointmentSchema.
	self registerHealthRouteOn: router.
	self registerSessionRouteOn: router.
	self registerPatientRoutesOn: router.
	self registerAppointmentRoutesOn: router.
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
				to: response ]
		operation: (OpenApiOperation new
			summary: 'Service health';
			operationId: 'health';
			tag: 'system';
			response: 200 description: 'Service status';
			yourself)
%
category: 'routes'
classmethod: SNApi
registerSessionRouteOn: aRouter
	| application |
	application := SNApplication current.
	aRouter
		post: '/sessions'
		do: [ :request :response |
			self
				createSessionFrom: request bodyContents
				in: application
				respondOn: response ]
		operation: (OpenApiOperation new
			summary: 'Sign in';
			operationId: 'createSession';
			tag: 'authentication';
			response: 201 description: 'Authenticated session' schema: (OpenApiSchema ref: 'Session');
			response: 401 description: 'Invalid credentials';
			yourself)
%
category: 'routes'
classmethod: SNApi
registerPatientRoutesOn: aRouter
	| application |
	application := SNApplication current.
	aRouter
		get: '/patients'
		do: [ :request :response |
			self
				withAuthenticatedUserFrom: request
				in: application
				respondOn: response
				do: [ :user |
					self
						writeJson: ((application patientsVisibleTo: user) collect: [ :patient |
							self patientAsDictionary: patient ]) asArray
						status: 200
						to: response ] ]
		operation: (OpenApiOperation new
			summary: 'List patients';
			operationId: 'listPatients';
			tag: 'patients';
			response: 200 description: 'Persisted patients' schema: (OpenApiSchema array: (OpenApiSchema ref: 'Patient'));
			response: 401 description: 'Authentication required';
			response: 403 description: 'Professional role required';
			yourself).
	aRouter
		post: '/patients'
		do: [ :request :response |
			self
				withAuthenticatedUserFrom: request
				in: application
				respondOn: response
				do: [ :user |
					self
						createPatientFrom: request bodyContents
						in: application
						requestedBy: user
						respondOn: response ] ]
		operation: (OpenApiOperation new
			summary: 'Create patient';
			operationId: 'createPatient';
			tag: 'patients';
			requestBodyJson: (OpenApiSchema ref: 'Patient');
			response: 201 description: 'Created patient' schema: (OpenApiSchema ref: 'Patient');
			response: 400 description: 'Invalid patient data';
			response: 401 description: 'Authentication required';
			response: 403 description: 'Professional role required';
			response: 409 description: 'Persistence conflict';
			yourself)
%
category: 'routes'
classmethod: SNApi
registerAppointmentRoutesOn: aRouter
	| application |
	application := SNApplication current.
	aRouter
		get: '/appointments'
		do: [ :request :response |
			self
				withAuthenticatedUserFrom: request
				in: application
				respondOn: response
				do: [ :user |
					self
						writeJson: ((application appointmentsVisibleTo: user) collect: [ :appointment |
							self appointmentAsDictionary: appointment ]) asArray
						status: 200
						to: response ] ]
		operation: (OpenApiOperation new
			summary: 'List visible appointments';
			operationId: 'listAppointments';
			tag: 'appointments';
			response: 200 description: 'Visible appointments' schema: (OpenApiSchema array: (OpenApiSchema ref: 'Appointment'));
			response: 401 description: 'Authentication required';
			yourself).
	aRouter
		post: '/appointments'
		do: [ :request :response |
			self
				withAuthenticatedUserFrom: request
				in: application
				respondOn: response
				do: [ :user |
					self
						createAppointmentFrom: request bodyContents
						in: application
						requestedBy: user
						respondOn: response ] ]
		operation: (OpenApiOperation new
			summary: 'Assign appointment';
			operationId: 'createAppointment';
			tag: 'appointments';
			response: 201 description: 'Assigned appointment' schema: (OpenApiSchema ref: 'Appointment');
			response: 400 description: 'Invalid appointment data';
			response: 401 description: 'Authentication required';
			response: 403 description: 'Professional role required';
			response: 409 description: 'Persistence conflict';
			yourself)
%
category: 'request handling'
classmethod: SNApi
createSessionFrom: aJsonString in: anApplication respondOn: aResponse
	| credentials session |
	session := [
		credentials := JsonParser parse: aJsonString.
		anApplication
			authenticateEmail: (credentials at: 'email')
			password: (credentials at: 'password') ]
		on: Error
		do: [ :exception |
			System abortTransaction.
			^ self
				writeError: 'invalid_credentials'
				message: 'Invalid email or password'
				status: 401
				to: aResponse ].
	System commitTransaction ifFalse: [
		System abortTransaction.
		^ self
			writeError: 'persistence_conflict'
			message: 'The session could not be committed'
			status: 409
			to: aResponse ].
	self
		writeJson: (self sessionAsDictionary: session)
		status: 201
		to: aResponse
%
category: 'request handling'
classmethod: SNApi
createPatientFrom: aJsonString in: anApplication requestedBy: aUser respondOn: aResponse
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
	anApplication addPatient: patient requestedBy: aUser.
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
category: 'request handling'
classmethod: SNApi
createAppointmentFrom: aJsonString in: anApplication requestedBy: aUser respondOn: aResponse
	| appointment patientId payload scheduledAt |
	payload := [ JsonParser parse: aJsonString ]
		on: Error
		do: [ :exception |
			System abortTransaction.
			^ self
				writeError: 'invalid_appointment'
				message: exception messageText
				status: 400
				to: aResponse ].
	scheduledAt := [
		patientId := payload at: 'patientId'.
		self dateAndTimeFromJsonValue: (payload at: 'scheduledAt') ]
		on: Error
		do: [ :exception |
			System abortTransaction.
			^ self
				writeError: 'invalid_appointment'
				message: exception messageText
				status: 400
				to: aResponse ].
	appointment := [
		anApplication
			scheduleAppointmentForPatientId: patientId
			at: scheduledAt
			requestedBy: aUser ]
		on: ArgumentError
		do: [ :exception |
			System abortTransaction.
			^ self
				writeError: 'invalid_appointment'
				message: exception messageText
				status: 400
				to: aResponse ].
	System commitTransaction ifFalse: [
		System abortTransaction.
		^ self
			writeError: 'persistence_conflict'
			message: 'The appointment could not be committed'
			status: 409
			to: aResponse ].
	self
		writeJson: (self appointmentAsDictionary: appointment)
		status: 201
		to: aResponse
%
category: 'authentication'
classmethod: SNApi
withAuthenticatedUserFrom: aRequest in: anApplication respondOn: aResponse do: aBlock
	| user |
	user := [
		(anApplication sessionForToken: (self bearerTokenFrom: aRequest)) user ]
		on: SNAuthenticationError
		do: [ :exception |
			self
				writeError: 'authentication_required'
				message: 'A valid session is required'
				status: 401
				to: aResponse.
			^ nil ].
	[ ^ aBlock value: user ]
		on: SNAuthorizationError
		do: [ :exception |
			self
				writeError: 'forbidden'
				message: exception messageText
				status: 403
				to: aResponse ]
%
category: 'authentication'
classmethod: SNApi
bearerTokenFrom: aRequest
	| authorization |
	authorization := aRequest headers
		at: 'authorization'
		ifAbsent: [ SNAuthenticationError signal: 'Authorization header missing' ].
	(authorization size > 7 and: [
		(authorization copyFrom: 1 to: 7) = 'Bearer ' ]) ifFalse: [
		SNAuthenticationError signal: 'Bearer token missing' ].
	^ authorization copyFrom: 8 to: authorization size
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
		at: 'id' put: aPatient id;
		at: 'givenName' put: aPatient givenName;
		at: 'familyName' put: aPatient familyName;
		at: 'birthDate' put: (self birthDateAsJsonValue: aPatient birthDate);
		yourself
%
category: 'serialization'
classmethod: SNApi
appointmentAsDictionary: anAppointment
	^ Dictionary new
		at: 'id' put: anAppointment id;
		at: 'patient' put: (self patientAsDictionary: anAppointment patient);
		at: 'scheduledAt' put: anAppointment scheduledAt asString;
		at: 'status' put: anAppointment status asString;
		yourself
%
category: 'serialization'
classmethod: SNApi
sessionAsDictionary: aSession
	^ Dictionary new
		at: 'accessToken' put: aSession token;
		at: 'user' put: (self userAsDictionary: aSession user);
		yourself
%
category: 'serialization'
classmethod: SNApi
userAsDictionary: aUser
	^ Dictionary new
		at: 'email' put: aUser email;
		at: 'displayName' put: aUser displayName;
		at: 'role' put: aUser role asString;
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
category: 'serialization'
classmethod: SNApi
dateAndTimeFromJsonValue: aString
	| normalized |
	normalized := aString last = $Z
		ifTrue: [ (aString copyFrom: 1 to: aString size - 1) , '+00:00' ]
		ifFalse: [ aString ].
	^ DateAndTime fromString: normalized
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
