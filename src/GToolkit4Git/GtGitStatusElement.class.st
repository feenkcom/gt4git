Class {
	#name : #GtGitStatusElement,
	#superclass : #BlElement,
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

	[ 
	self removeChildren.
	aRepository statusModel do: [ :status | 
		self addChild: status asElement ] ] asAsyncFuture await
]

{ #category : #accessing }
GtGitStatusElement >> onRepositoryModified: anAnnouncement [
	self initializeOn: anAnnouncement repository
]

{ #category : #accessing }
GtGitStatusElement >> repository: aRepository [
	self subscribeTo: aRepository viewModel.
	self initializeOn: aRepository.
]

{ #category : #accessing }
GtGitStatusElement >> subscribeTo: aViewModel [
	aViewModel weak when: GtRepositoryModified send: #onRepositoryModified: to: self
]
