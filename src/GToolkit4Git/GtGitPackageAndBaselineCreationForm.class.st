Class {
	#name : #GtGitPackageAndBaselineCreationForm,
	#superclass : #Object,
	#instVars : [
		'repositoryModel',
		'package',
		'button',
		'baseline',
		'addToReadme'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> acceptAction [
	<magritteActionDescription>
	^ MAActionDescription new
		label: 'Accept';
		action: [ :aModel :aButton | 
			[ | aPackage |
			aPackage := self addPackage.
			self addPackageToBaseline: aPackage.
			self addInstallationInstructions.
			button
				inUIProcessDo: [ button dispatchEvent: BrDropdownHideWish new.
					button phlow fireUpdateWish ] ] on: Error do: #debug ];
		beCommitAction
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> addInstallationInstructions [
	| readme |
	self addToReadme ifFalse: [ ^ self ].

	readme := self repositoryModel repository repositoryDirectory / 'README.md'.
	readme
		writeStreamDo: [ :s | 
			s
				nextPutAll: '##Installation

```
Metacello new
	repository: ''' , self guessRepository
						, ''';
	baseline: ''' , (self baseline removePrefix: 'BaselineOf')
						, ''';
	load
```' ].
	self repositoryModel repository addFileToIndex: 'README.md'.
	self repositoryModel announceRepositoryModified
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> addPackage [
	| packageClass |
	self package ifEmpty: [ ^ self ].

	packageClass := Smalltalk classNamed: self package.
	packageClass ifNil: [ ^ self repositoryModel addPackage: self package ].

	self repositoryModel icebergWorkingCopy addPackageNamed: self package.
	^ packageClass
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> addPackageToBaseline: aPackage [
	| baselineMethod baselineClass |
	baseline ifEmpty: [ ^ self ].

	baselineClass := Smalltalk classNamed: baseline.
	baselineClass
		ifNil: [ ^ self repositoryModel
				addBaseline: baseline
				withPackages: (aPackage ifNil: [ {} ] ifNotNil: [ {aPackage} ]) ].

	aPackage
		ifNotNil: [ baselineMethod := baselineClass >> #baseline:.
			(RBAddMethodChange
				compile: baselineMethod sourceCode allButLast
						, '.
			spec package: ''' , aPackage name , ''''
						, '
		]'
				in: baselineClass
				classified: #baseline) execute ]
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> addToReadme [
	^ addToReadme
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> addToReadme: anObject [
	addToReadme := anObject
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> addToReadmeDescription [
	<magritteDescription>
	^ MABooleanDescription new
		label: 'Add Installation to README';
		priority: 3;
		accessor: #addToReadme
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> asElement [
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
GtGitPackageAndBaselineCreationForm >> baseline [
	^ baseline
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> baseline: anObject [
	baseline := anObject
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> baselineDescription [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Baseline';
		priority: 2;
		accessor: #baseline;
		textStyler: #glamorousCodeFont;
		blocCompletion: [ GtStringsCompletionStrategy new
				completions: (GtPrefixTree withAll: repositoryModel baselines) ];
		addCondition: [ :aValue | aValue isEmpty or: [ aValue trim beginsWith: 'BaselineOf' ] ]
			labelled: 'Baseline name must start with BaselineOf';
		addCondition: [ :aValue | aValue trim isAllAlphaNumerics ]
			labelled: 'Baseline name must be alphanumeric'
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> button [
	^ button
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> button: anObject [
	button := anObject
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> guessRepository [
	| parser parsed |
	self repositoryModel repository originUrl isEmptyOrNil ifTrue: [ ^ '' ].

	parser := self urlParser.
	parsed := parser parse: self repositoryModel repository originUrl.
	^ 'github://' , (parsed at: 1) , '/' , (parsed at: 2) , ':'
		, self repositoryModel repository branchName , '/' , self repositoryModel repository subdirectory
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> initialize [
	package := ''.
	baseline := ''.
	addToReadme := true
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> package [
	^ package
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> package: anObject [
	package := anObject
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> packageDescription [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Package';
		priority: 1;
		accessor: #package;
		textStyler: #glamorousCodeFont;
		blocCompletion: [ GtStringsCompletionStrategy new
				completions: (GtPrefixTree withAll: (Smalltalk allClasses collect: #name)) ]
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> repositoryModel [
	^ repositoryModel
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> repositoryModel: anObject [
	repositoryModel := anObject.
	self package: (' ' join: ('-' split: repositoryModel name)) asCamelCase.
	self baseline: 'BaselineOf' , self package.
	repositoryModel baselines
		ifNotEmpty: [ :baselines | self baseline: baselines first ]
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> urlParser [
	| user domain organization repository ssh separator https |
	user := '@' asPParser negate plus flatten.
	domain := 'github.com' asPParser.
	ssh := (user , '@' asPParser , domain , ':' asPParser)
			==> [ :t | 
				{t first.
					t third} ].
	separator := '/' asPParser.
	https := ('https://' asPParser , separator negate plus flatten , separator)
			==> #second.
	organization := separator negate plus flatten.
	repository := '.git' asPParser negate plus flatten.
	^ (https / ssh , organization , separator , repository , '.git' asPParser)
		==> [ :t | 
			{t second.
				t fourth} ]
]
