Class {
	#name : #GtGitDefinitionsElement,
	#superclass : #BrExpander,
	#instVars : [
		'repositoryViewModel'
	],
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #accessing }
GtGitDefinitionsElement >> addDefinitionEditorShortcutsTo: aPropertiesElement [
	aPropertiesElement addShortcut: (BlShortcutWithAction new
		combination: BlKeyCombination arrowUp;
		action: [ :anEvent |
			anEvent currentTarget deepestFocusedChild ifNotNil: [ :aFocusedChild |
				BlFocusFinder new
					up;
					root: anEvent currentTarget;
					referenceElement: aFocusedChild;
					nextFocusDo: [ :aNextFocusElement | aNextFocusElement requestFocus ] ] ]).

	aPropertiesElement addShortcut: (BlShortcutWithAction new
		combination: BlKeyCombination arrowDown;
		action: [ :anEvent |
			anEvent currentTarget deepestFocusedChild ifNotNil: [ :aFocusedChild |
				BlFocusFinder new
					down;
					root: anEvent currentTarget;
					referenceElement: aFocusedChild;
					nextFocusDo: [ :aNextFocusElement | aNextFocusElement requestFocus ] ] ]).
]

{ #category : #accessing }
GtGitDefinitionsElement >> buildDefinitionEditor [

	| theProperties |
	theProperties := BrHorizontalGrid new constraintsDo: [ :c | 
		                 c horizontal matchParent.
		                 c vertical fitContent ].

	self addDefinitionEditorShortcutsTo: theProperties.

	theProperties addChild:
		self repositoryModel asGtMagritteViewModel asElement.

	^ theProperties
]

{ #category : #accessing }
GtGitDefinitionsElement >> buildDefinitionReader [

	| theProperties |
	theProperties := BrHorizontalGrid new constraintsDo: [ :c | 
		                 c horizontal matchParent.
		                 c vertical fitContent ].

	theProperties addChild:
		(self repositoryModel asGtMagritteViewModelWithDescription:
			 self repositoryModel branchDescription beReadOnly
			 , self repositoryModel originDescription beReadOnly) asElement.

	^ theProperties
]

{ #category : #accessing }
GtGitDefinitionsElement >> buildErrorMessage [
	^ self repositoryViewModel statusModel first asLabelElement
]

{ #category : #accessing }
GtGitDefinitionsElement >> initialize [
	super initialize.	

	self
		aptitude: GtCoderExpanderAptitude;
		hMatchParent;
		vFitContent
]

{ #category : #accessing }
GtGitDefinitionsElement >> repository [

	^ self repositoryViewModel repositoryModel repository
]

{ #category : #accessing }
GtGitDefinitionsElement >> repositoryModel [
	^ self repositoryViewModel repositoryModel
]

{ #category : #accessing }
GtGitDefinitionsElement >> repositoryViewModel [
	^ repositoryViewModel
]

{ #category : #accessing }
GtGitDefinitionsElement >> repositoryViewModel: aViewModel [
	repositoryViewModel := aViewModel.
	self updateElements.
]

{ #category : #accessing }
GtGitDefinitionsElement >> updateElements [

	self header: [ 
		(self repositoryViewModel hasRepository not or: [ 
			 self repositoryViewModel isCommittable ])
			ifTrue: [ self buildDefinitionReader ]
			ifFalse: [ self buildErrorMessage ] ].
	self content: [ 
		(self repositoryViewModel hasRepository not or: [ 
			 self repositoryViewModel isCommittable ])
			ifTrue: [ self buildDefinitionEditor ]
			ifFalse: [ self buildErrorMessage ] ]
]
