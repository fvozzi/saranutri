set compile_env: 0
! ------------------- Class definition for SNApplication
expectvalue /Class
doit
Object subclass: 'SNApplication'
  instVarNames: #()
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
