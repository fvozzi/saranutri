set compile_env: 0
! ------------------- Class definition for SNApiTest
expectvalue /Class
doit
TestCase subclass: 'SNApiTest'
  instVarNames: #(birthDate patient)
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UserGlobals
  options: #()
%
expectvalue /Class
doit
SNApiTest category: 'SaraNutri-Tests'
%
! ------------------- Instance methods for SNApiTest
category: 'running'
method: SNApiTest
setUp
	super setUp.
	birthDate := Date
		fromString: '1815-12-10'
		usingFormat: #(3 2 1 $- 1 1).
	patient := SNPatient
		named: 'Ada'
		familyName: 'Lovelace'
		birthDate: birthDate
%
category: 'tests'
method: SNApiTest
testPatientAsDictionary
	| dictionary |
	dictionary := SNApi patientAsDictionary: patient.

	self assert: (dictionary at: 'id') equals: patient id.
	self assert: (dictionary at: 'givenName') equals: 'Ada'.
	self assert: (dictionary at: 'familyName') equals: 'Lovelace'.
	self assert: (dictionary at: 'birthDate') equals: '1815-12-10'
%
category: 'tests'
method: SNApiTest
testPatientFromDictionary
	| dictionary parsedPatient |
	dictionary := Dictionary new
		at: 'givenName' put: 'Ada';
		at: 'familyName' put: 'Lovelace';
		at: 'birthDate' put: '1815-12-10';
		yourself.
	parsedPatient := SNApi patientFromDictionary: dictionary.

	self assert: parsedPatient givenName equals: 'Ada'.
	self assert: parsedPatient familyName equals: 'Lovelace'.
	self assert: parsedPatient birthDate equals: birthDate
%
category: 'tests'
method: SNApiTest
testPatientWithoutBirthDateRoundTripsAsJsonNull
	| dictionary patientWithoutBirthDate |
	patientWithoutBirthDate := SNPatient
		named: 'Grace'
		familyName: 'Hopper'
		birthDate: nil.
	dictionary := SNApi patientAsDictionary: patientWithoutBirthDate.

	self assert: (dictionary at: 'birthDate') isNil
%
category: 'tests'
method: SNApiTest
testDateAndTimeFromUtcJsonValue
	| dateAndTime |
	dateAndTime := SNApi
		dateAndTimeFromJsonValue: '2026-11-02T13:30:00.000Z'.

	self
		assert: (dateAndTime asString copyFrom: 1 to: 10)
		equals: '2026-11-02'
%
category: 'tests'
method: SNApiTest
testSessionAsDictionary
	| dictionary session user |
	user := SNProfessionalUser
		named: 'Sara Nutri'
		email: 'professional@example.com'
		password: 'secret'.
	session := SNAuthenticatedSession forUser: user.
	dictionary := SNApi sessionAsDictionary: session.

	self assert: (dictionary at: 'accessToken') equals: session token.
	self assert: ((dictionary at: 'user') at: 'role') equals: 'professional'
%
