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
GtGitDefinitionsElement >> addNewDatabaseInDirectory: aDirectory [

	| aDatabase aFileLocator |
	aFileLocator := aDirectory gtWithClosestFileLocatorParent.
	aDatabase := LeLocalStoreLoad current loadAndMonitorFrom:
		             aFileLocator.

	LeDatabasesRegistry uniqueInstance ensureDatabase addDB: aDatabase.

	LeDatabasesRegistry defaultLogicalDatabase properties 
		addRegisteredDirectory: aFileLocator.

	self repository addFileToIndex:
		(aDirectory relativeTo: self repository repositoryDirectory).
	self repositoryViewModel repositoryModel lepiterWorkingCopy addDB:
		aDatabase
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

	| theProperties theReaders |
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
GtGitDefinitionsElement >> buildSectionLabel: aSectionName [
	
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new glamorousRegularFontAndSize foreground: Color gray; fontSize: 12);
		text: aSectionName, ':';
		focusability: BlFocusability none;
		margin: (BlInsets top: 5 right: 2);
		constraintsDo: [ :c | c grid horizontal alignLeft ]
]

{ #category : #accessing }
GtGitDefinitionsElement >> buttonMargin [
	^ BlInsets top: 3 left: 0 bottom: 3 right: 5
]

{ #category : #accessing }
GtGitDefinitionsElement >> editableLabelLook [
	^ BrGlamorousEditableLabelAptitude new
		glamorousCodeFont;
		defaultForeground: Color black;
		fontSize: 10
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
GtGitDefinitionsElement >> readonlyLabelLook [
	^ BrGlamorousEditorAptitude new
		glamorousCodeFont;
		fontSize: 10;
		foreground: Color black;
		add:
			(BrStyleCommonAptitude new
				default: [ :aStyle | 
					aStyle
						geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
						border: BlBorder empty ];
				hovered: [ :aStyle | 
					aStyle
						border: (BlBorder paint: self theme button hoveredBorderColor width: 1) ]);
		yourself
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
