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
GtGitPackageAndBaselineCreationForm >> addInstallationInstructions [
	| readme |
	self addToReadme ifFalse: [ ^ self ].

	readme := self repositoryModel repository repositoryDirectory / 'README.md'.
	readme
		writeStreamDo: [ :s | 
			s setToEnd
				nextPutAll: '## Installation

```st
Metacello new
	repository: ''' , self guessRepository
						, ''';
	baseline: ''' , (self baseline removePrefix: 'BaselineOf')
						, ''';
	load
```

' ].
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
	baseline ifEmpty: [ ^ false ].

	baselineClass := Smalltalk classNamed: baseline.
	baselineClass
		ifNil: [ self repositoryModel
				addBaseline: baseline
				withPackages: (aPackage ifNil: [ {} ] ifNotNil: [ {aPackage} ]).
			^ true ].

	aPackage
		ifNotNil: [ baselineMethod := baselineClass >> #baseline:.
			(RBAddMethodChange
				compile: (baselineMethod sourceCode allButLast: 4)
						, '.
			spec package: ''' , aPackage name , ''''
						, '
		]'
				in: baselineClass
				classified: #baseline) execute ].
	^ false
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
		editorAptitude: [ BrGlamorousRegularEditorAptitude new glamorousFormEditorCodeFontAndSize ];
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ];
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
GtGitPackageAndBaselineCreationForm >> githubUrlParser [
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

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> gitlabUrlParser [
	| user domain organization repository ssh separator https |
	user := '@' asPParser negate plus flatten.
	domain := 'gitlab.com' asPParser.
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

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> guessRepository [
	| parser parsed |
	self repositoryModel repository origin isUndefined ifTrue: [ ^ '' ].

	parser := self selectParser.
	parsed := parser parse: self repositoryModel repository originUrl.
	^ self selectPrefix , (parsed at: 1) , '/' , (parsed at: 2) , ':'
		, self repositoryModel repository branchName , '/'
		, self repositoryModel repository subdirectory
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> initialize [
	package := ''.
	baseline := ''.
	addToReadme := true
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> magritteAcceptAction [
	<magritteActionDescription>

	^ super magritteAcceptAction
		onSuccessCallback: (GtMagritteCallback new
			action: [ :aModel :aButton :aMemento :aDescription | 
				[ | aPackage newBaseline |
				aPackage := self addPackage.
				newBaseline := self addPackageToBaseline: aPackage.
				newBaseline ifTrue: [ self addInstallationInstructions ].
				button enqueueTask: (BlTaskAction new action: [
					button dispatchEvent: BrDropdownHideWish new.
					button phlow fireToolUpdateWish
				]) ] on: Error do: #debug ]);
		beEnabledOnValidOverallStatus.
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
		editorAptitude: [ BrGlamorousRegularEditorAptitude new glamorousFormEditorCodeFontAndSize ];
		labelAptitude: [ BrGlamorousLabelAptitude new glamorousFormLabelStyle ];
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
GtGitPackageAndBaselineCreationForm >> selectParser [
	| url |
	url := self repositoryModel repository originUrl.

	(url includesSubstring: 'github.com') ifTrue: [ ^ self githubUrlParser ].
	(url includesSubstring: 'gitlab.com') ifTrue: [ ^ self gitlabUrlParser ].

	^ self
		error: 'The URL schema could not be parsed—currently only GitHub and GitLab URLs are supported to add Baseline information to the README.'
]

{ #category : #accessing }
GtGitPackageAndBaselineCreationForm >> selectPrefix [
	| url |
	url := self repositoryModel repository originUrl.

	(url includesSubstring: 'github.com') ifTrue: [ ^ 'github://' ].
	(url includesSubstring: 'gitlab.com') ifTrue: [ ^ 'gitlab://' ].

	^ self
		error: 'The URL schema could not be parsed—currently only GitHub and GitLab URLs are supported to add Baseline information to the README.'
]
