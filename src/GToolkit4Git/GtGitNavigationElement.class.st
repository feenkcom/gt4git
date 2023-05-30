Class {
	#name : #GtGitNavigationElement,
	#superclass : #BlElement,
	#traits : 'TBrLayoutResizable',
	#classTraits : 'TBrLayoutResizable classTrait',
	#instVars : [
		'navigationModel',
		'suppressed'
	],
	#category : #'GToolkit4Git-UI'
}

{ #category : #accessing }
GtGitNavigationElement >> addAndSelectRepository: aRepositoryAnnouncement [

	aRepositoryAnnouncement repository ifNil: [ ^ self ].

	suppressed ifFalse: [ 
		suppressed := true.
		self
			allChildrenBreadthFirstDetect: [ :aChild | 
			aChild isKindOf: BrColumnedList ]
			ifFound: [ :aList | 
				"aList viewModel items add: aRepositoryAnnouncement repository.
				aList selectOne: aList viewModel itemCount.
				aList scrollToIndex: aList viewModel itemCount" ] ].

	suppressed := false
]

{ #category : #accessing }
GtGitNavigationElement >> announcer [
	^ navigationModel announcer
]

{ #category : #accessing }
GtGitNavigationElement >> initialize [
	super initialize.
	self matchParent.
	suppressed := false
]

{ #category : #accessing }
GtGitNavigationElement >> navigationModel: aGtGitNavigationModel [
	navigationModel := aGtGitNavigationModel.
	self announcer weak when: GtGitRepositoryAddedAndSelected send: #addAndSelectRepository: to: self.
	self announcer weak when: GtGitRepositorySelected send: #selectRepository: to: self
]

{ #category : #accessing }
GtGitNavigationElement >> selectRepository: aRepositoryAnnouncement [

	aRepositoryAnnouncement repository
		ifNil: [
			(self query // GtPhlowColumnedListId) anyOne ifNotNil: [ :aList | aList deselectAll ].
			^ self ].

	suppressed ifFalse: [ 
		suppressed := true.
		
		(self query // GtPhlowColumnedListId) anyOne ifNotNil: [ :aList |
			aList viewModel items doWithIndex: [ :each :index | 
					each name = aRepositoryAnnouncement repository name ifTrue: [ 
						aList selectOne: index.
						aList scrollToIndex: index ] ] ] ].

	suppressed := false
]
