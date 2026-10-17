set compile_env: 0
! ------------------- Class definition for SNApplication
expectvalue /Class
doit
Object subclass: 'SNApplication'
  instVarNames: #(patients)
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
	patients := OrderedCollection new
%
category: 'accessing'
method: SNApplication
patients
	^ patients copy
%
category: 'patients'
method: SNApplication
addPatient: aPatient
	patients add: aPatient.
	^ aPatient
%
