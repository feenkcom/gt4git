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
	theProperties := BlElement new
		                 layout: (BlGridLayout new columnCount: 2);
		                 constraintsDo: [ :c | 
			                 c horizontal matchParent.
			                 c vertical fitContent ].

	self addDefinitionEditorShortcutsTo: theProperties.

	self editors do: [ :eachEditor | 
		theProperties addChildren: { 
				(self buildSectionLabel: eachEditor title).
				eachEditor asElement } ].

	^ theProperties
]

{ #category : #accessing }
GtGitDefinitionsElement >> buildDefinitionReader [
	| theProperties theReaders |

	theProperties := BlElement new
		layout: (BlGridLayout new columnCount: 2);
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ].

	theReaders := self readers.
	theReaders := theReaders first: (2 min: theReaders size).
	theReaders do: [ :eachEditor |
		theProperties addChildren: { 
				(self buildSectionLabel: eachEditor title).
				(eachEditor
					aptitude: [ self readonlyLabelLook ];
					margin: self buttonMargin;
					asElement) } ].

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
GtGitDefinitionsElement >> editors [

	| repository |
	self repositoryViewModel hasRepository ifFalse: [ ^ #(  ) ].

	repository := self repositoryViewModel repositoryModel repository.
	^ { 
		  (GtGitDefinitionsEditor new
			   title: 'Branch';
			   repository: repository;
			   getSelector: #branchName;
			   completions:
				   (repository allBranches collect: [ :branch | branch name ]);
			   setSelector: #checkoutBranch:).
		  (GtGitDefinitionsEditor new
			   title: 'Origin';
			   repository: repository;
			   getSelector: #originUrl;
			   setSelector: #setOriginTo:).
		  (GtGitDefinitionsStaticDropdownEditor new
			   title: 'File Format';
			   value: repository writerClass description;
			   options: { 'Tonel'. 'Filetree' };
			   action: [ :format | 
				   | model |
				   model := IceBasicProject onRepository: repository.
				   model fileFormat: (format = 'Tonel'
							    ifTrue: [ IceLibgitTonelWriter ]
							    ifFalse: [ IceLibgitFiletreeWriter ]).
				   repository workingCopy project: model.
				   Iceberg announcer announce:
						   (IceRepositoryModified for: repository) ]).
		  (GtGitDefinitionsDropdownEditor new
			   title: 'Code Directory';
			   value: repository codeDirectory;
			   contentBlock: [ :dropdown | 
				   | fileBrowser container |
				   container := BlElement new
					                layout: (BlGridLayout new columnCount: 1);
					                padding: (BlInsets all: 8);
					                aptitude: BrWidgetContainerAptitude.
				   container constraintsDo: [ :c | 
					   c horizontal fitContent.
					   c vertical fitContent ].
				   fileBrowser := BrFileSelector new folder:
					                  repository codeDirectory.

				   fileBrowser vExact: 250.
				   fileBrowser hExact: 400.

				   fileBrowser buttonLabel: 'Set'.
				   fileBrowser okAction: [ :filePath | 
					   repository codeDirectory: (filePath  relativeTo: repository repositoryDirectory) pathString.
					   Iceberg announcer announce:
						   (IceRepositoryAnnouncement for: repository).
					   dropdown ifNotNil: [ 
						   dropdown enqueueTask: (BlTaskAction new action: [ 
								    dropdown dispatchEvent:
									    (BrDropdownHideWish new anchor: dropdown) ]) ] ].

				   fileBrowser fileFilterBlock: [ :aFileReference | 
					   aFileReference isDirectory and: [ 
						   (FileSystemDirectoryEntry reference: aFileReference) isHidden
							   not ] ].
				   container addChild: fileBrowser.
				   container ]) }
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
GtGitDefinitionsElement >> readers [
	self repositoryViewModel hasRepository ifFalse: [ ^#() ].

	^ { 
		  (GtGitDefinitionsReader new
			   title: 'Branch';
			   repository: self repositoryViewModel repositoryModel repository;
			   getSelector: #branchName).
		  (GtGitDefinitionsReader new
			   title: 'Origin';
			   repository: self repositoryViewModel repositoryModel repository;
			   getSelector: #originUrl)}
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
