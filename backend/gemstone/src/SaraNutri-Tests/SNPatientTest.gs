set compile_env: 0
! ------------------- Class definition for SNPatientTest
expectvalue /Class
doit
TestCase subclass: 'SNPatientTest'
  instVarNames: #()
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UserGlobals
  options: #()
%
expectvalue /Class
doit
SNPatientTest category: 'SaraNutri-Tests'
%
! ------------------- Instance methods for SNPatientTest
category: 'tests'
method: SNPatientTest
testPatientHasStableIdentifier
	| patient |
	patient := SNPatient
		named: 'Ada'
		familyName: 'Lovelace'
		birthDate: nil.

	self deny: patient id isEmpty.
	self assert: patient id equals: patient id
%
category: 'tests'
method: SNPatientTest
testPatientNamesAreNormalized
	| patient |
	patient := SNPatient
		named: '  Ada  '
		familyName: '  Lovelace  '
		birthDate: nil.

	self assert: patient givenName equals: 'Ada'.
	self assert: patient familyName equals: 'Lovelace'
%
category: 'tests'
method: SNPatientTest
testPatientNamesAcceptUnicodeLetters
	| patient |
	patient := SNPatient
		named: 'María'
		familyName: 'Muñoz'
		birthDate: nil.

	self assert: patient givenName equals: 'María'.
	self assert: patient familyName equals: 'Muñoz'
%
category: 'tests'
method: SNPatientTest
testBlankGivenNameIsRejected
	self
		should: [
			SNPatient
				named: '  '
				familyName: 'Lovelace'
				birthDate: nil ]
		raise: ArgumentError
%
category: 'tests'
method: SNPatientTest
testPatientNameWithNonLetterIsRejected
	self
		should: [
			SNPatient
				named: 'Ada2'
				familyName: 'Lovelace'
				birthDate: nil ]
		raise: ArgumentError
%
category: 'tests'
method: SNPatientTest
testBlankFamilyNameIsRejected
	self
		should: [
			SNPatient
				named: 'Ada'
				familyName: '  '
				birthDate: nil ]
		raise: ArgumentError
%
