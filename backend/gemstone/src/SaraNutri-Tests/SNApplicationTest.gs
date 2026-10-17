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
