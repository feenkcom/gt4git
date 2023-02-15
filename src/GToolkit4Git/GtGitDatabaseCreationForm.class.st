Class {
	#name : #GtGitDatabaseCreationForm,
	#superclass : #Object,
	#instVars : [
		'directory',
		'baseline',
		'repositoryModel',
		'button'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitDatabaseCreationForm >> acceptAction [
	<magritteActionDescription>
	^ MAActionDescription new
		label: 'Accept';
		action: [ :aModel :aButton | 
			[ self directory ensureCreateDirectory.
			self repositoryModel addNewDatabaseInDirectory: self directory.
			self
				addToBaseline: (self directory relativeTo: self repositoryModel repository repositoryDirectory)
						pathString.
			button
				inUIProcessDo: [ button dispatchEvent: BrDropdownHideWish new.
					button phlow fireUpdateWish ] ] on: Error do: #debug ];
		beCommitAction
]

{ #category : #accessing }
GtGitDatabaseCreationForm >> addToBaseline: aDatabaseFolder [
	| baselineClass |
	baseline ifEmpty: [ ^ self ].
	
	baselineClass := baseline asClass.
	(RBAddMethodChange
		compile: 'loadLepiter
	IceRepository registry  
		detect: [ :aRepository |
			aRepository name = '''
				, self repositoryModel name
				, ''' ]
		ifFound: [ :aRepository | 
			| defaultDatabase currentProperties |
			defaultDatabase := LeDatabasesRegistry defaultLogicalDatabase.
			currentProperties := defaultDatabase properties.
			currentProperties addRegisteredDirectory: aRepository repositoryDirectory / '
				, aDatabaseFolder
				, '.
			defaultDatabase reload ]
		ifNone: [
			self inform: ''Repository not found.'' ]'
		in: baselineClass
		classified: #loading) execute.

	self addToReadme
]

{ #category : #accessing }
GtGitDatabaseCreationForm >> addToReadme [
	| readme |
	readme := self repositoryModel repository repositoryDirectory / 'README.md'.
	readme
		writeStreamDo: [ :s | 
			s setToEnd
				nextPutAll: '## Load Lepiter
				
After installing with Metacello, you will be able to execute

```
#' , self baseline
						, ' asClass loadLepiter
```

' ].
	self repositoryModel repository addFileToIndex: 'README.md'.
	self repositoryModel announceRepositoryModified
]

{ #category : #accessing }
GtGitDatabaseCreationForm >> asElement [
	| viewModel |
	viewModel := self asGtMagritteViewModel.
	viewModel actions first
		installOn: [ :aModel :aButton :aMemento | 
			aButton
				withAsyncSinkDo: [ :anElementSink | 
					anElementSink
						sink: AsyncPeekSink new;
						whenUpdate: [ :theButton :aSink | 
							| aStatus |
							aStatus := aSink value.
							theButton enabled: aStatus isValid ].
					aMemento overallStatus observe: anElementSink ] ].
	viewModel
		onElementCreated: [ :aFrame | 
			BlFocusFinder new
				direction: BlFocusSearchDirectionForward new;
				root: aFrame;
				referenceElement: nil;
				nextFocusDo: #requestFocus ifNone: [  ] ].
	^ viewModel asElement padding: (BlInsets all: 5)
]

{ #category : #accessing }
GtGitDatabaseCreationForm >> baseline [
	^ baseline
]

{ #category : #accessing }
GtGitDatabaseCreationForm >> baseline: anObject [
	baseline := anObject
]

{ #category : #accessing }
GtGitDatabaseCreationForm >> baselineDescription [
	<magritteDescription>
	^ MASingleOptionDescription new
		label: 'Baseline';
		priority: 2;
		accessor: #baseline;
		textStyler: #glamorousCodeFont;
		display: [ :aString | aString ifEmpty: [ 'No Baseline' ] ifNotEmpty: [ aString ] ];
		options: (repositoryModel baselines
				addFirst: '';
				yourself)
]

{ #category : #accessing }
GtGitDatabaseCreationForm >> button [
	^ button
]

{ #category : #accessing }
GtGitDatabaseCreationForm >> button: anObject [
	button := anObject
]

{ #category : #accessing }
GtGitDatabaseCreationForm >> databaseDescription [
	<magritteDescription>
	^ MADirectoryDescription new
		label: 'Location';
		priority: 1;
		kind: AbstractFileReference;
		display: [ :aFileRef | 
			(aFileRef relativeTo: self repositoryModel repository repositoryDirectory)
				pathString ];
		accessor: #directory
]

{ #category : #accessing }
GtGitDatabaseCreationForm >> directory [
	^ directory
]

{ #category : #accessing }
GtGitDatabaseCreationForm >> directory: anObject [
	directory := anObject
]

{ #category : #accessing }
GtGitDatabaseCreationForm >> initialize [
	baseline := ''
]

{ #category : #accessing }
GtGitDatabaseCreationForm >> repositoryModel [
	^ repositoryModel
]

{ #category : #accessing }
GtGitDatabaseCreationForm >> repositoryModel: anObject [
	repositoryModel := anObject.
	self directory: self repositoryModel repository repositoryDirectory / 'lepiter'.
	repositoryModel hasBaseline
		ifTrue: [ self baseline: repositoryModel baselines first ]
]
