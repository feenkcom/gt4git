Class {
	#name : #GtGitPackageCreationForm,
	#superclass : #Object,
	#instVars : [
		'repositoryModel',
		'package',
		'button',
		'baseline'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitPackageCreationForm >> acceptAction [
	<magritteActionDescription>
	^ MAActionDescription new
		label: 'Accept';
		action: [ :aModel :aButton | 
			[ | aPackage |
			aPackage := self addPackage.
			self addPackageToBaseline: aPackage.
			button
				inUIProcessDo: [ button dispatchEvent: BrDropdownHideWish new.
					button phlow fireUpdateWish.
					button phlow
						spawnTool: (GtPackageCoderTool package: self package asPackage) ] ]
				on: Error
				do: #debug ];
		beCommitAction
]

{ #category : #accessing }
GtGitPackageCreationForm >> addPackage [
	| packageClass |
	self package ifEmpty: [ ^ self ].

	packageClass := Smalltalk classNamed: self package.
	packageClass ifNil: [ ^ self repositoryModel addPackage: self package ].

	self repositoryModel icebergWorkingCopy addPackageNamed: self package.
	^ packageClass
]

{ #category : #accessing }
GtGitPackageCreationForm >> addPackageToBaseline: aPackage [
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
				in: baseline
				classified: #baseline) execute ]
]

{ #category : #accessing }
GtGitPackageCreationForm >> asElement [
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
GtGitPackageCreationForm >> baseline [
	^ baseline
]

{ #category : #accessing }
GtGitPackageCreationForm >> baseline: anObject [
	baseline := anObject
]

{ #category : #accessing }
GtGitPackageCreationForm >> baselineDescription [
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
GtGitPackageCreationForm >> button [
	^ button
]

{ #category : #accessing }
GtGitPackageCreationForm >> button: anObject [
	button := anObject
]

{ #category : #accessing }
GtGitPackageCreationForm >> initialize [
	package := ''.
	baseline := ''
]

{ #category : #accessing }
GtGitPackageCreationForm >> package [
	^ package
]

{ #category : #accessing }
GtGitPackageCreationForm >> package: anObject [
	package := anObject
]

{ #category : #accessing }
GtGitPackageCreationForm >> packageDescription [
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
GtGitPackageCreationForm >> repositoryModel [
	^ repositoryModel
]

{ #category : #accessing }
GtGitPackageCreationForm >> repositoryModel: anObject [
	repositoryModel := anObject.
	self package: (' ' join: ('-' split: repositoryModel name)) asCamelCase.
	repositoryModel baselines
		ifNotEmpty: [ :baselines | self baseline: baselines first ]
]
