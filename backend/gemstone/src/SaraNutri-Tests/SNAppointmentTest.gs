set compile_env: 0
! ------------------- Class definition for SNAppointmentTest
expectvalue /Class
doit
TestCase subclass: 'SNAppointmentTest'
  instVarNames: #(patient scheduledAt)
  classVars: #()
  classInstVars: #()
  poolDictionaries: #()
  inDictionary: UserGlobals
  options: #()
%
expectvalue /Class
doit
SNAppointmentTest category: 'SaraNutri-Tests'
%
! ------------------- Instance methods for SNAppointmentTest
category: 'running'
method: SNAppointmentTest
setUp
	super setUp.
	patient := SNPatient
		named: 'Ada'
		familyName: 'Lovelace'
		birthDate: nil.
	scheduledAt := DateAndTime now
%
category: 'tests'
method: SNAppointmentTest
testAppointmentStoresPatientAndScheduledTime
	| appointment |
	appointment := SNAppointment
		forPatient: patient
		scheduledAt: scheduledAt.

	self assert: appointment patient == patient.
	self assert: appointment scheduledAt equals: scheduledAt
%
category: 'tests'
method: SNAppointmentTest
testNewAppointmentIsScheduled
	| appointment |
	appointment := SNAppointment
		forPatient: patient
		scheduledAt: scheduledAt.

	self assert: appointment status equals: #scheduled.
	self assert: appointment isScheduled
%
category: 'tests'
method: SNAppointmentTest
testAppointmentRejectsInvalidPatient
	self
		should: [
			SNAppointment
				forPatient: Object new
				scheduledAt: scheduledAt ]
		raise: ArgumentError
%
category: 'tests'
method: SNAppointmentTest
testAppointmentRequiresScheduledTime
	self
		should: [
			SNAppointment
				forPatient: patient
				scheduledAt: nil ]
		raise: ArgumentError
%
