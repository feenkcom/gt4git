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
	self announcer weak when: GtGitRepositorySelected send: #selectRepository: to: self
]

{ #category : #accessing }
GtGitNavigationElement >> selectRepository: aRepositoryAnnouncement [

	suppressed ifFalse: [ 
		suppressed := true.
		self allChildrenBreadthFirstDetect: [ :aChild | 
			aChild isKindOf: BrColumnedList ]
			ifFound: [ :aList | 
				aList viewModel items doWithIndex: [ :each :index | 
					each name = aRepositoryAnnouncement repository name ifTrue: [ 
						aList selectOne: index.
						aList scrollToIndex: index ] ] ] ].

	suppressed := false
]
