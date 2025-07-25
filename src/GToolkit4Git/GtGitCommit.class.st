Class {
	#name : #GtGitCommit,
	#superclass : #IceGitCommit,
	#instVars : [
		'lepiterWorkingCopy',
		'fileSystem',
		'project'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitCommit >> fileSystem [
	fileSystem ifNotNil: [ ^ fileSystem ].
	^ fileSystem := repository isGitCliRepository
			ifTrue: [ (repository commitFromGitCommit: id) fileSystem ]
			ifFalse: [ super fileSystem ]
]

{ #category : #accessing }
GtGitCommit >> gtActionCheckoutFor: anAction [
	<gtAction>
	^ anAction dropdown
		label: 'Checkout';
		content: [ :aDropdown | 
			BrSimpleList new
				margin: (BlInsets all: 5);
				items: IceCheckoutStrategy allGtStrategies;
				itemStencil: [ BrLabel new hMatchParent
						aptitude: BrGlamorousLabelAptitude + BrGlamorousListItemAptitude ];
				itemDataBinder: [ :aLabel :aStrategy | 
					aLabel
						text: aStrategy gtDescription;
						when: BlClickEvent
							do: [ :_ | 
								aStrategy
									committish: self;
									lepiterWorkingCopy: self lepiterWorkingCopy;
									checkoutOn: self repository workingCopy.
								aDropdown fireEvent: BrDropdownHideWish new ] ] ]
]

{ #category : #'gt - extensions' }
GtGitCommit >> gtVerificationFor: aView [
	<gtView>
	(PureGitUrl with: self repository origin url) gitHubWebUrl
		ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Verification';
		priority: 60;
		object: [ (PureGitRepository on: self repository location) queries
				resolveCommit: self id ];
		view: #gtVerificationFor:
]

{ #category : #accessing }
GtGitCommit >> lepiterWorkingCopy [
	^ lepiterWorkingCopy
]

{ #category : #accessing }
GtGitCommit >> lepiterWorkingCopy: aLepiterWorkingCopy [
	lepiterWorkingCopy := aLepiterWorkingCopy
]

{ #category : #accessing }
GtGitCommit >> project [
	^project ifNil: [project := super project]
]

{ #category : #accessing }
GtGitCommit >> tags [
	^ (repository respondsTo: #tagsFor:)
		ifTrue: [ repository tagsFor: id ]
		ifFalse: [ repository tags select: [ :each | each commit = self ] ]
]
