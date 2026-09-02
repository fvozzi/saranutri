set compile_env: 0
! ------------------- Class definition for SNPatient
expectvalue /Class
doit
Object subclass: 'SNPatient'
  instVarNames: #(givenName familyName birthDate)
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
! ------------------- Instance methods for SNPatient
category: 'accessing'
method: SNPatient
givenName
	^ givenName
%
category: 'accessing'
method: SNPatient
givenName: aString
	givenName := aString
%
category: 'accessing'
method: SNPatient
familyName
	^ familyName
%
category: 'accessing'
method: SNPatient
familyName: aString
	familyName := aString
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
category: 'printing'
method: SNPatient
displayName
	^ String streamContents: [ :stream |
		stream
			nextPutAll: (familyName ifNil: [ '' ]);
			nextPutAll: ', ';
			nextPutAll: (givenName ifNil: [ '' ]) ]
%
