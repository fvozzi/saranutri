set compile_env: 0
! ------------------- Class definition for SNPatient
expectvalue /Class
doit
Object subclass: 'SNPatient'
  instVarNames: #(id givenName familyName birthDate)
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UserGlobals
  options: #()
%
expectvalue /Class
doit
SNPatient category: 'SaraNutri-Domain'
%
! ------------------- Class methods for SNPatient
category: 'instance creation'
classmethod: SNPatient
new
	^ self basicNew
		initialize;
		yourself
%
category: 'instance creation'
classmethod: SNPatient
named: aGivenName familyName: aFamilyName birthDate: aBirthDate
	^ self new
		givenName: aGivenName;
		familyName: aFamilyName;
		birthDate: aBirthDate;
		yourself
%
! ------------------- Instance methods for SNPatient
category: 'initialization'
method: SNPatient
initialize
	id := GsUuidV4 new asString
%
category: 'accessing'
method: SNPatient
id
	^ id ifNil: [ id := GsUuidV4 new asString ]
%
category: 'accessing'
method: SNPatient
givenName
	^ givenName
%
category: 'accessing'
method: SNPatient
givenName: aString
	givenName := self normalizedName: aString
%
category: 'accessing'
method: SNPatient
familyName
	^ familyName
%
category: 'accessing'
method: SNPatient
familyName: aString
	familyName := self normalizedName: aString
%
category: 'accessing'
method: SNPatient
birthDate
	^ birthDate
%
category: 'accessing'
method: SNPatient
birthDate: aDate
	birthDate := aDate
%
category: 'validation'
method: SNPatient
normalizedName: aString
	| normalizedName |
	normalizedName := aString trimWhiteSpace.
	normalizedName isEmpty ifTrue: [
		ArgumentError signal: 'Patient names are required' ].
	(normalizedName allSatisfy: [ :character | character isLetter ]) ifFalse: [
		ArgumentError signal: 'Patient names must contain only letters' ].
	^ normalizedName
%
category: 'printing'
method: SNPatient
displayName
	^ String streamContents: [ :stream |
		stream
			nextPutAll: (familyName ifNil: [ '' ]);
			nextPutAll: ', ';
			nextPutAll: (givenName ifNil: [ '' ]) ]
%
