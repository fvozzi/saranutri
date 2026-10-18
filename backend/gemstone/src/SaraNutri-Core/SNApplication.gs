set compile_env: 0
! ------------------- Class definition for SNApplication
expectvalue /Class
doit
Object subclass: 'SNApplication'
  instVarNames: #(patients appointments users sessions)
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UserGlobals
  options: #()
%
expectvalue /Class
doit
SNApplication category: 'SaraNutri-Core'
%
! ------------------- Class methods for SNApplication
category: 'instance creation'
classmethod: SNApplication
new
	^ self basicNew
		initialize;
		yourself
%
category: 'accessing'
classmethod: SNApplication
current
	^ self currentIn: UserGlobals
%
category: 'private'
classmethod: SNApplication
currentIn: aRegistry
	^ aRegistry
		at: #SaraNutriApplication
		ifAbsentPut: [ self new ]
%
category: 'accessing'
classmethod: SNApplication
applicationName
	^ 'SaraNutri'
%
category: 'accessing'
classmethod: SNApplication
applicationVersion
	^ '0.1.0'
%
! ------------------- Instance methods for SNApplication
category: 'initialization'
method: SNApplication
initialize
	patients := OrderedCollection new.
	appointments := OrderedCollection new.
	users := OrderedCollection new.
	sessions := Dictionary new
%
category: 'accessing'
method: SNApplication
patients
	patients ifNil: [ patients := OrderedCollection new ].
	^ patients copy
%
category: 'accessing'
method: SNApplication
appointments
	appointments ifNil: [ appointments := OrderedCollection new ].
	^ appointments copy
%
category: 'accessing'
method: SNApplication
users
	users ifNil: [ users := OrderedCollection new ].
	^ users copy
%
category: 'patients'
method: SNApplication
addPatient: aPatient
	patients ifNil: [ patients := OrderedCollection new ].
	patients add: aPatient.
	^ aPatient
%
category: 'patients'
method: SNApplication
addPatient: aPatient requestedBy: aUser
	aUser patientsFrom: #().
	^ self addPatient: aPatient
%
category: 'patients'
method: SNApplication
patientsVisibleTo: aUser
	^ aUser patientsFrom: self patients
%
category: 'patients'
method: SNApplication
patientWithId: anId
	^ self patients
		detect: [ :patient | patient id = anId ]
		ifNone: [ ArgumentError signal: 'Patient not found' ]
%
category: 'appointments'
method: SNApplication
appointmentsVisibleTo: aUser
	^ (aUser appointmentsFrom: self appointments)
		asSortedCollection: [ :first :second |
			first scheduledAt <= second scheduledAt ]
%
category: 'appointments'
method: SNApplication
scheduleAppointmentForPatientId: aPatientId at: aDateAndTime requestedBy: aUser
	| appointment patient |
	aUser assertCanManageAppointments.
	patient := self patientWithId: aPatientId.
	appointment := SNAppointment
		forPatient: patient
		scheduledAt: aDateAndTime.
	appointments ifNil: [ appointments := OrderedCollection new ].
	appointments add: appointment.
	^ appointment
%
category: 'users'
method: SNApplication
addProfessionalNamed: aDisplayName email: anEmail password: aPassword
	^ self addUser: (SNProfessionalUser
		named: aDisplayName
		email: anEmail
		password: aPassword)
%
category: 'users'
method: SNApplication
addPatientUserFor: aPatient email: anEmail password: aPassword
	(self patients includes: aPatient) ifFalse: [
		ArgumentError signal: 'A patient user requires a persisted patient' ].
	^ self addUser: (SNPatientUser
		forPatient: aPatient
		email: anEmail
		password: aPassword)
%
category: 'users'
method: SNApplication
addUser: aUser
	users ifNil: [ users := OrderedCollection new ].
	(users anySatisfy: [ :existing | existing matchesEmail: aUser email ]) ifTrue: [
		ArgumentError signal: 'A user with this email already exists' ].
	users add: aUser.
	^ aUser
%
category: 'authentication'
method: SNApplication
authenticateEmail: anEmail password: aPassword
	| session user |
	user := self users
		detect: [ :candidate |
			(candidate matchesEmail: anEmail) and: [
				candidate hasPassword: aPassword ] ]
		ifNone: [
			SNAuthenticationError signal: 'Invalid email or password' ].
	session := SNAuthenticatedSession forUser: user.
	sessions ifNil: [ sessions := Dictionary new ].
	sessions at: session token put: session.
	^ session
%
category: 'authentication'
method: SNApplication
sessionForToken: aToken
	| session |
	sessions ifNil: [ sessions := Dictionary new ].
	session := sessions
		at: aToken
		ifAbsent: [ SNAuthenticationError signal: 'Invalid session' ].
	session isActive ifFalse: [
		sessions removeKey: aToken ifAbsent: [ ].
		SNAuthenticationError signal: 'Expired session' ].
	^ session
%
