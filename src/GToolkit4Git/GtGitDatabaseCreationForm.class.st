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
			currentProperties addRegisteredDirectory: aRepository repositoryDirectory / '''
				, aDatabaseFolder
				, '''.
			defaultDatabase reload ]
		ifNone: [
			self inform: ''Repository not found.'' ]'
		in: baselineClass class
		classified: #loading) execute.

	self addToReadme
]

{ #category : #accessing }
GtGitDatabaseCreationForm >> addToReadme [
	| readme |
	readme := self repositoryModel repository repositoryDirectory / 'README.md'.
	readme writeStreamDo: [ :stream | 
		stream setToEnd.
		(ZnNewLineWriterStream on: stream) nextPutAll: '
## Load Lepiter

After installing with Metacello, you will be able to execute

```
#' , self baseline , ' asClass loadLepiter
```
' ].
	self repositoryModel repository addFileToIndex: 'README.md'.
	self repositoryModel announceRepositoryModified
]

{ #category : #accessing }
GtGitDatabaseCreationForm >> asElement [
	| viewModel |
	viewModel := self asGtMagritteViewModel.
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
		editorAptitude: [ BrGlamorousRegularEditorAptitude new glamorousFormEditorCodeFontAndSize ];
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ];
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
GtGitDatabaseCreationForm >> magritteAcceptAction [
	<magritteActionDescription>
	^ super magritteAcceptAction
		onSuccessCallback: [ [ self directory ensureCreateDirectory.
			self repositoryModel addNewDatabaseInDirectory: self directory.
			self
				addToBaseline: (self directory relativeTo: self repositoryModel repository repositoryDirectory)
						pathString.
			button dispatchEvent: BrDropdownHideWish new.
			button phlow fireToolUpdateWish ] on: Error do: #debug ];
		beEnabledOnValidOverallStatus
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
