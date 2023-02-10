Class {
	#name : #GtGitBaselineCreationForm,
	#superclass : #Object,
	#instVars : [
		'repositoryModel',
		'baseline',
		'button',
		'readmeInstructions'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitBaselineCreationForm >> acceptAction [
	<magritteActionDescription>
	^ MAActionDescription new
		label: 'Accept';
		action: [ :aModel :aButton | 
			[ self repositoryModel addBaselineWithAllPackages: self baseline.

			self readmeInstructions
				ifTrue: [ | readme |
					readme := self repositoryModel repository repositoryDirectory / 'README.md'.
					readme
						writeStreamDo: [ :s | 
							s
								nextPutAll: '##Installation

```
Metacello new
	repository: '''';
	baseline: '''
										, (self baseline removePrefix: 'BaselineOf')
										, ''';
	load
```' ].
					self repositoryModel repository addFileToIndex: 'README.md'.
					self repositoryModel announceRepositoryModified ].

			button
				inUIProcessDo: [ button dispatchEvent: BrDropdownHideWish new.
					button phlow
						spawnTool: (GtMethodCoderTool compiledMethod: self baseline asClass >> #baseline:) ] ]
				on: Error
				do: #debug ];
		beCommitAction
]

{ #category : #accessing }
GtGitBaselineCreationForm >> asElement [
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
GtGitBaselineCreationForm >> baseline [
	^ baseline
]

{ #category : #accessing }
GtGitBaselineCreationForm >> baseline: anObject [
	baseline := anObject
]

{ #category : #accessing }
GtGitBaselineCreationForm >> baselineDescription [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Baseline';
		priority: 1;
		accessor: #baseline;
		textStyler: #glamorousCodeFont;
		blocCompletion: [ GtStringsCompletionStrategy new
				completions: (GtPrefixTree withAll: (Smalltalk allClasses collect: #name)) ];
		addCondition: [ :aValue | aValue asString trim isNotEmpty ]
			labelled: 'Baseline name must be set';
		addCondition: [ :aValue | (Smalltalk classNamed: aValue asString trim) isNil ]
			labelled: 'Baseline name is already taken';
		addCondition: [ :aValue | aValue beginsWith: 'BaselineOf' ]
			labelled: 'Baseline name must start with BaselineOf';
		addCondition: [ :aValue | aValue asString isAllAlphaNumerics ]
			labelled: 'Baseline name must be alphanumeric';
		beRequired
]

{ #category : #accessing }
GtGitBaselineCreationForm >> button [
	^ button
]

{ #category : #accessing }
GtGitBaselineCreationForm >> button: anObject [
	button := anObject
]

{ #category : #accessing }
GtGitBaselineCreationForm >> initialize [
	baseline := ''.
	readmeInstructions := false
]

{ #category : #accessing }
GtGitBaselineCreationForm >> installationDescription [
	<magritteDescription>
	^ MABooleanDescription new
		label: 'Add installation instructions to README';
		priority: 2;
		accessor: #readmeInstructions
]

{ #category : #accessing }
GtGitBaselineCreationForm >> readmeInstructions [
	^ readmeInstructions
]

{ #category : #accessing }
GtGitBaselineCreationForm >> readmeInstructions: anObject [
	readmeInstructions := anObject
]

{ #category : #accessing }
GtGitBaselineCreationForm >> repositoryModel [
	^ repositoryModel
]

{ #category : #accessing }
GtGitBaselineCreationForm >> repositoryModel: anObject [
	repositoryModel := anObject.
	self baseline: 'BaselineOf', (' ' join: ('-' split: repositoryModel name)) asCamelCase
]