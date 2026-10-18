set compile_env: 0
! ------------------- Error classes
expectvalue /Class
doit
Error subclass: 'SNAuthenticationError'
  instVarNames: #()
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UserGlobals
  options: #()
%
expectvalue /Class
doit
SNAuthenticationError category: 'SaraNutri-Domain'
%
expectvalue /Class
doit
Error subclass: 'SNAuthorizationError'
  instVarNames: #()
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UserGlobals
  options: #()
%
expectvalue /Class
doit
SNAuthorizationError category: 'SaraNutri-Domain'
%
! ------------------- Class definition for SNUser
expectvalue /Class
doit
Object subclass: 'SNUser'
  instVarNames: #(email displayName passwordSalt passwordDigest)
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UserGlobals
  options: #()
%
expectvalue /Class
doit
SNUser category: 'SaraNutri-Domain'
%
! ------------------- Instance methods for SNUser
category: 'initialization'
method: SNUser
initializeEmail: anEmail displayName: aDisplayName password: aPassword
	email := self normalizedEmail: anEmail.
	displayName := self normalizedRequiredText: aDisplayName.
	self setPassword: aPassword
%
category: 'accessing'
method: SNUser
email
	^ email
%
category: 'accessing'
method: SNUser
displayName
	^ displayName
%
category: 'authentication'
method: SNUser
hasPassword: aPassword
	^ passwordDigest = (self digestForPassword: aPassword)
%
category: 'authentication'
method: SNUser
setPassword: aPassword
	| normalizedPassword |
	normalizedPassword := self normalizedRequiredText: aPassword.
	passwordSalt := GsUuidV4 new asString.
	passwordDigest := self digestForPassword: normalizedPassword
%
category: 'authentication'
method: SNUser
digestForPassword: aPassword
	| digest |
	digest := passwordSalt , ':' , aPassword.
	1 to: 20000 do: [ :iteration |
		digest := (passwordSalt , ':' , digest) asSha256String ].
	^ digest
%
category: 'testing'
method: SNUser
matchesEmail: anEmail
	^ email = (self normalizedEmail: anEmail)
%
category: 'validation'
method: SNUser
normalizedEmail: aString
	| normalizedEmail |
	normalizedEmail := (self normalizedRequiredText: aString) asLowercase.
	(normalizedEmail includes: $@) ifFalse: [
		ArgumentError signal: 'A user email must be valid' ].
	^ normalizedEmail
%
category: 'validation'
method: SNUser
normalizedRequiredText: aString
	| normalizedText |
	normalizedText := aString trimWhiteSpace.
	normalizedText isEmpty ifTrue: [
		ArgumentError signal: 'User text is required' ].
	^ normalizedText
%
category: 'roles'
method: SNUser
role
	self subclassResponsibility
%
category: 'roles'
method: SNUser
patientsFrom: aCollection
	self subclassResponsibility
%
category: 'roles'
method: SNUser
appointmentsFrom: aCollection
	self subclassResponsibility
%
category: 'roles'
method: SNUser
assertCanManageAppointments
	self subclassResponsibility
%

! ------------------- Class definition for SNProfessionalUser
expectvalue /Class
doit
SNUser subclass: 'SNProfessionalUser'
  instVarNames: #()
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UserGlobals
  options: #()
%
expectvalue /Class
doit
SNProfessionalUser category: 'SaraNutri-Domain'
%
! ------------------- Class methods for SNProfessionalUser
category: 'instance creation'
classmethod: SNProfessionalUser
named: aDisplayName email: anEmail password: aPassword
	^ self new
		initializeEmail: anEmail displayName: aDisplayName password: aPassword;
		yourself
%
! ------------------- Instance methods for SNProfessionalUser
category: 'roles'
method: SNProfessionalUser
role
	^ #professional
%
category: 'roles'
method: SNProfessionalUser
patientsFrom: aCollection
	^ aCollection copy
%
category: 'roles'
method: SNProfessionalUser
appointmentsFrom: aCollection
	^ aCollection copy
%
category: 'roles'
method: SNProfessionalUser
assertCanManageAppointments
	^ self
%

! ------------------- Class definition for SNPatientUser
expectvalue /Class
doit
SNUser subclass: 'SNPatientUser'
  instVarNames: #(patient)
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UserGlobals
  options: #()
%
expectvalue /Class
doit
SNPatientUser category: 'SaraNutri-Domain'
%
! ------------------- Class methods for SNPatientUser
category: 'instance creation'
classmethod: SNPatientUser
forPatient: aPatient email: anEmail password: aPassword
	^ self new
		initializePatient: aPatient email: anEmail password: aPassword;
		yourself
%
! ------------------- Instance methods for SNPatientUser
category: 'initialization'
method: SNPatientUser
initializePatient: aPatient email: anEmail password: aPassword
	patient := aPatient.
	self
		initializeEmail: anEmail
		displayName: aPatient displayName
		password: aPassword
%
category: 'accessing'
method: SNPatientUser
patient
	^ patient
%
category: 'roles'
method: SNPatientUser
role
	^ #patient
%
category: 'roles'
method: SNPatientUser
patientsFrom: aCollection
	SNAuthorizationError signal: 'Patients cannot manage patient profiles'
%
category: 'roles'
method: SNPatientUser
appointmentsFrom: aCollection
	^ aCollection select: [ :appointment | appointment patient == patient ]
%
category: 'roles'
method: SNPatientUser
assertCanManageAppointments
	SNAuthorizationError signal: 'Patients cannot assign appointments'
%

! ------------------- Class definition for SNAuthenticatedSession
expectvalue /Class
doit
Object subclass: 'SNAuthenticatedSession'
  instVarNames: #(token user expiresAt)
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UserGlobals
  options: #()
%
expectvalue /Class
doit
SNAuthenticatedSession category: 'SaraNutri-Domain'
%
! ------------------- Class methods for SNAuthenticatedSession
category: 'instance creation'
classmethod: SNAuthenticatedSession
forUser: aUser
	^ self new
		initializeForUser: aUser;
		yourself
%
! ------------------- Instance methods for SNAuthenticatedSession
category: 'initialization'
method: SNAuthenticatedSession
initializeForUser: aUser
	token := GsUuidV4 new asString.
	user := aUser.
	expiresAt := DateAndTime now + (Duration seconds: 43200)
%
category: 'accessing'
method: SNAuthenticatedSession
token
	^ token
%
category: 'accessing'
method: SNAuthenticatedSession
user
	^ user
%
category: 'testing'
method: SNAuthenticatedSession
isActive
	^ DateAndTime now < expiresAt
%
