Class {
	#name : #GtGitPackageCreationForm,
	#superclass : #Object,
	#instVars : [
		'repositoryModel',
		'package',
		'button'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitPackageCreationForm >> acceptAction [
	<magritteActionDescription>
	^ MAActionDescription new
		label: 'Accept';
		action: [ :aModel :aButton | 
			[ self repositoryModel addPackage: self package.
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
GtGitPackageCreationForm >> button [
	^ button
]

{ #category : #accessing }
GtGitPackageCreationForm >> button: anObject [
	button := anObject
]

{ #category : #accessing }
GtGitPackageCreationForm >> initialize [
	package := ''
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
				completions: (GtPrefixTree withAll: (Smalltalk allClasses collect: #name)) ];
		addCondition: [ :aValue | aValue asString trim isNotEmpty ]
			labelled: 'Package name must be set';
		addCondition: [ :aValue | (Smalltalk classNamed: aValue asString trim) isNil ]
			labelled: 'Package name is already taken';
		beRequired
]

{ #category : #accessing }
GtGitPackageCreationForm >> repositoryModel [
	^ repositoryModel
]

{ #category : #accessing }
GtGitPackageCreationForm >> repositoryModel: anObject [
	repositoryModel := anObject.
	self package: (' ' join: ('-' split: repositoryModel name)) asCamelCase
]
