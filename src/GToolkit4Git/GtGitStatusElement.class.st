Class {
	#name : #GtGitStatusElement,
	#superclass : #BlElement,
	#instVars : [
		'session',
		'currentFuture'
	],
	#category : #'GToolkit4Git-UI'
}

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

	currentFuture
		ifNil: [ future await ]
		ifNotNil: [ currentFuture then: [ future await ] ].

	currentFuture := future
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
