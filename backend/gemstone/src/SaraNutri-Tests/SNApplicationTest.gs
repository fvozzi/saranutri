set compile_env: 0
! ------------------- Class definition for SNApplicationTest
expectvalue /Class
doit
TestCase subclass: 'SNApplicationTest'
  instVarNames: #(application patient)
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UserGlobals
  options: #()
%
expectvalue /Class
doit
SNApplicationTest category: 'SaraNutri-Tests'
%
! ------------------- Instance methods for SNApplicationTest
category: 'running'
method: SNApplicationTest
setUp
	super setUp.
	application := SNApplication new.
	patient := SNPatient new
		givenName: 'Ada';
		familyName: 'Lovelace';
		yourself
%
category: 'tests'
method: SNApplicationTest
testNewApplicationHasNoPatients
	self assert: application patients isEmpty
%
category: 'tests'
method: SNApplicationTest
testAddingPatientStoresPatient
	application addPatient: patient.

	self assert: application patients size equals: 1.
	self assert: application patients first == patient
%
category: 'tests'
method: SNApplicationTest
testAddingPatientAnswersPatient
	self assert: (application addPatient: patient) == patient
%
category: 'tests'
method: SNApplicationTest
testPatientsAnswersSnapshot
	| snapshot |
	application addPatient: patient.
	snapshot := application patients.
	snapshot remove: patient.

	self assert: application patients size equals: 1
%
category: 'tests'
method: SNApplicationTest
testCurrentApplicationIsStoredInRegistry
	| registry currentApplication |
	registry := Dictionary new.
	currentApplication := SNApplication currentIn: registry.

	self assert: (SNApplication currentIn: registry) == currentApplication
%
category: 'tests'
method: SNApplicationTest
testProfessionalCanAuthenticateAndManageAppointments
	| appointment session user |
	application addPatient: patient.
	user := application
		addProfessionalNamed: 'Sara Nutri'
		email: 'professional@example.com'
		password: 'secret'.
	session := application
		authenticateEmail: 'PROFESSIONAL@example.com'
		password: 'secret'.
	appointment := application
		scheduleAppointmentForPatientId: patient id
		at: DateAndTime now + (Duration seconds: 3600)
		requestedBy: session user.

	self assert: session user == user.
	self assert: application appointments size equals: 1.
	self assert: appointment patient == patient
%
category: 'tests'
method: SNApplicationTest
testPatientOnlySeesOwnAppointments
	| anotherPatient patientSession professional |
	anotherPatient := SNPatient
		named: 'Grace'
		familyName: 'Hopper'
		birthDate: nil.
	application
		addPatient: patient;
		addPatient: anotherPatient.
	professional := application
		addProfessionalNamed: 'Sara Nutri'
		email: 'professional@example.com'
		password: 'secret'.
	application
		scheduleAppointmentForPatientId: patient id at: DateAndTime now + (Duration seconds: 3600) requestedBy: professional;
		scheduleAppointmentForPatientId: anotherPatient id at: DateAndTime now + (Duration seconds: 7200) requestedBy: professional.
	application
		addPatientUserFor: patient
		email: 'ada@example.com'
		password: 'secret'.
	patientSession := application
		authenticateEmail: 'ada@example.com'
		password: 'secret'.

	self assert: (application appointmentsVisibleTo: patientSession user) size equals: 1.
	self
		should: [ application patientsVisibleTo: patientSession user ]
		raise: SNAuthorizationError
%
category: 'tests'
method: SNApplicationTest
testInvalidCredentialsAreRejected
	application
		addProfessionalNamed: 'Sara Nutri'
		email: 'professional@example.com'
		password: 'secret'.

	self
		should: [
			application
				authenticateEmail: 'professional@example.com'
				password: 'incorrect' ]
		raise: SNAuthenticationError
%
