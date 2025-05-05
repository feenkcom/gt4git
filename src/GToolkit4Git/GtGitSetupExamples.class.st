Class {
	#name : #GtGitSetupExamples,
	#superclass : #Object,
	#traits : 'TGtExampleAssertable',
	#classTraits : 'TGtExampleAssertable classTrait',
	#instVars : [
		'lepiterExamples'
	],
	#category : #'GToolkit4Git-Examples'
}

{ #category : #accessing }
GtGitSetupExamples >> cleanUpRepositoriesAndDatabases [
	lepiterExamples cleanUpRepositoriesAndDatabases
]

{ #category : #accessing }
GtGitSetupExamples >> simpleSetupView [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	<return: #BlElement>
	| repository view setupItems executedItems |
	lepiterExamples := GtIceLepiterExamples new.
	repository := lepiterExamples gitRepositoryAWithNoLepiterDatabase.

	(repository gtSetupHelpFor: GtPhlowView empty)
		asElementDo: [ :anElement | view := anElement ].

	setupItems := view children second items.
	executedItems := setupItems select: #isExecuted.
	self assert: executedItems size equals: 1.
	self assert: executedItems first class name = #GtGitRepositorySourceSetupItem.
	self assert: (setupItems reject: #isExecuted) size equals: 2.

	^ view
]

{ #category : #accessing }
GtGitSetupExamples >> simpleSetupViewWithLepiter [
	<gtExample>
	<after: #cleanUpRepositoriesAndDatabases>
	<return: #BlElement>
	| repository view setupItems |
	lepiterExamples := GtIceLepiterExamples new.
	repository := lepiterExamples
			gitRepositoryAWithNewEmptyNotCommitedLepiterDatabase.

	(repository gtSetupHelpFor: GtPhlowView empty)
		asElementDo: [ :anElement | view := anElement ].

	setupItems := view children second items.

	self assert: (setupItems select: #isExecuted) size = 2.
	self assert: (setupItems reject: #isExecuted) size = 1.

	^ view
]
