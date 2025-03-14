Class {
	#name : #GtGitStatusElement,
	#superclass : #BlElement,
	#instVars : [
		'session',
		'currentPromise',
		'futureConfiguration'
	],
	#category : #'GToolkit4Git-UI'
}

{ #category : #initialization }
GtGitStatusElement >> defaultFutureConfiguration [
	^ AsyncFutureExecutionConfiguration new 
		customGroup: #Git;
		lowPriority
]

{ #category : #accessing }
GtGitStatusElement >> futureConfiguration [
	<return: #AsyncFutureExecutionConfiguration>
	^ futureConfiguration ifNil: [ 
		futureConfiguration := self defaultFutureConfiguration ]
]

{ #category : #accessing }
GtGitStatusElement >> futureConfiguration: aAsyncFutureExecutionConfiguration [
	futureConfiguration := aAsyncFutureExecutionConfiguration
]

{ #category : #accessing }
GtGitStatusElement >> initialize [
	super initialize.

	self
		layout: BlLinearLayout horizontal;
		constraintsDo: [ :c | 
			c vertical fitContent.
			c horizontal fitContent ].
]

{ #category : #accessing }
GtGitStatusElement >> initializeOn: aRepository [
	| future |
	future := [ (session isNotNil and: [ Smalltalk session == session ])
			ifTrue: [ self removeChildren.
				aRepository statusModel do: [ :status | self addChild: status asElement ] ] ]
			asAsyncFuture.

	(currentPromise isNil or: [ currentPromise isFulfilled ])
		ifTrue: [ currentPromise := future await: self futureConfiguration ]
		ifFalse: [ currentPromise then: [ currentPromise := future await: self futureConfiguration ] ].
		
	self enqueueTask: (BlPromiseTask new promise: currentPromise)
]

{ #category : #accessing }
GtGitStatusElement >> onRepositoryModified: anAnnouncement [
	self initializeOn: anAnnouncement repository
]

{ #category : #accessing }
GtGitStatusElement >> repository: aRepository [
	session ifNotNil: [ ^ self ].
	session := Smalltalk session.
	self subscribeTo: aRepository viewModel.
	self initializeOn: aRepository.
]

{ #category : #accessing }
GtGitStatusElement >> subscribeTo: aViewModel [
	aViewModel weak when: GtRepositoryModified send: #onRepositoryModified: to: self
]
