Class {
	#name : #GtGitLepiterDatabaseCreationStencil,
	#superclass : #BrStencil,
	#instVars : [
		'dropdown',
		'repositoryModel',
		'database'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitLepiterDatabaseCreationStencil >> addDatabaseFor: aDirectory in: anElement [
	self repositoryModel addNewDatabaseInDirectory: aDirectory.
	anElement inUIProcessDo: [ anElement dispatchEvent: BrDropdownHideWish new ]
]

{ #category : #accessing }
GtGitLepiterDatabaseCreationStencil >> create [
	| container srcSelector |
	container := BrVerticalPane new
			aptitude: BrGlamorousWithVerticalResizerAptitude
					+ BrGlamorousWithHorizontalResizerAptitude.
	container size: 600 @ 350.
	container padding: (BlInsets all: 10).
	srcSelector := BrFileSelector new
			folder: self repositoryModel repository repositoryDirectory.

	container
		addChild: (BrButton new
				aptitude: BrGlamorousButtonWithLabelAptitude;
				label: 'Create in "lepiter"';
				action: [ self
						addDatabaseFor: self repositoryModel repository repositoryDirectory / 'lepiter' in: container ]).

	container addChild: srcSelector.
	srcSelector okAction: [ :srcFolder | self addDatabaseFor: srcFolder in: container ].
	srcSelector
		fileFilterBlock: [ :aFileReference | 
			aFileReference isDirectory
				and: [ (FileSystemDirectoryEntry reference: aFileReference) isHidden not ] ].

	^ container
]

{ #category : #accessing }
GtGitLepiterDatabaseCreationStencil >> database [
	^ database
]

{ #category : #accessing }
GtGitLepiterDatabaseCreationStencil >> database: anObject [
	database := anObject
]

{ #category : #accessing }
GtGitLepiterDatabaseCreationStencil >> dropdown [
	^ dropdown
]

{ #category : #accessing }
GtGitLepiterDatabaseCreationStencil >> dropdown: anObject [
	dropdown := anObject
]

{ #category : #accessing }
GtGitLepiterDatabaseCreationStencil >> repositoryModel [
	^ repositoryModel
]

{ #category : #accessing }
GtGitLepiterDatabaseCreationStencil >> repositoryModel: anObject [
	repositoryModel := anObject.
	database := repositoryModel repository repositoryDirectory
]
