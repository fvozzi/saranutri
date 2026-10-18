set compile_env: 0
! ------------------- Class definition for SNUserTest
expectvalue /Class
doit
TestCase subclass: 'SNUserTest'
  instVarNames: #(patient)
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UserGlobals
  options: #()
%
expectvalue /Class
doit
SNUserTest category: 'SaraNutri-Tests'
%
! ------------------- Instance methods for SNUserTest
category: 'running'
method: SNUserTest
setUp
	super setUp.
	patient := SNPatient
		named: 'Ada'
		familyName: 'Lovelace'
		birthDate: nil
%
category: 'tests'
method: SNUserTest
testProfessionalUserAuthenticatesAndNormalizesEmail
	| user |
	user := SNProfessionalUser
		named: 'Sara Nutri'
		email: ' PROFESSIONAL@Example.com '
		password: 'secret'.

	self assert: user email equals: 'professional@example.com'.
	self assert: user displayName equals: 'Sara Nutri'.
	self assert: user role equals: #professional.
	self assert: (user hasPassword: 'secret').
	self deny: (user hasPassword: 'incorrect')
%
category: 'tests'
method: SNUserTest
testPatientUserOnlyAnswersAppointmentsForItsPatient
	| anotherPatient appointments ownAppointment user |
	anotherPatient := SNPatient
		named: 'Grace'
		familyName: 'Hopper'
		birthDate: nil.
	ownAppointment := SNAppointment
		forPatient: patient
		scheduledAt: DateAndTime now + (Duration seconds: 3600).
	appointments := Array
		with: ownAppointment
		with: (SNAppointment
			forPatient: anotherPatient
			scheduledAt: DateAndTime now + (Duration seconds: 7200)).
	user := SNPatientUser
		forPatient: patient
		email: 'ada@example.com'
		password: 'secret'.

	self assert: (user appointmentsFrom: appointments) size equals: 1.
	self assert: (user appointmentsFrom: appointments) first == ownAppointment
%
category: 'tests'
method: SNUserTest
testPatientUserCannotManageAppointments
	| user |
	user := SNPatientUser
		forPatient: patient
		email: 'ada@example.com'
		password: 'secret'.

	self
		should: [ user assertCanManageAppointments ]
		raise: SNAuthorizationError
%
