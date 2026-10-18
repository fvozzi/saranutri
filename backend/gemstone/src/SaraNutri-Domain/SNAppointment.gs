set compile_env: 0
! ------------------- Class definition for SNAppointment
expectvalue /Class
doit
Object subclass: 'SNAppointment'
  instVarNames: #(id patient scheduledAt status)
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UserGlobals
  options: #()
%
expectvalue /Class
doit
SNAppointment category: 'SaraNutri-Domain'
%
! ------------------- Class methods for SNAppointment
category: 'instance creation'
classmethod: SNAppointment
forPatient: aPatient scheduledAt: aDateAndTime
	^ self new
		patient: aPatient;
		scheduledAt: aDateAndTime;
		yourself
%
category: 'instance creation'
classmethod: SNAppointment
new
	^ self basicNew
		initialize;
		yourself
%
! ------------------- Instance methods for SNAppointment
category: 'initialization'
method: SNAppointment
initialize
	id := GsUuidV4 new asString.
	status := #scheduled
%
category: 'accessing'
method: SNAppointment
id
	^ id ifNil: [ id := GsUuidV4 new asString ]
%
category: 'accessing'
method: SNAppointment
patient
	^ patient
%
category: 'accessing'
method: SNAppointment
patient: aPatient
	(aPatient isKindOf: SNPatient) ifFalse: [
		ArgumentError signal: 'An appointment requires a patient' ].
	patient := aPatient
%
category: 'accessing'
method: SNAppointment
scheduledAt
	^ scheduledAt
%
category: 'accessing'
method: SNAppointment
scheduledAt: aDateAndTime
	(aDateAndTime isKindOf: DateAndTime) ifFalse: [
		ArgumentError signal: 'An appointment requires a scheduled date and time' ].
	(aDateAndTime > DateAndTime now) ifFalse: [
		ArgumentError signal: 'An appointment must be scheduled in the future' ].
	scheduledAt := aDateAndTime
%
category: 'accessing'
method: SNAppointment
status
	^ status
%
category: 'testing'
method: SNAppointment
isScheduled
	^ status == #scheduled
%
