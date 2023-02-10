Class {
	#name : #GtGitBaselineCreationForm,
	#superclass : #Object,
	#instVars : [
		'repositoryModel',
		'baseline'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitBaselineCreationForm >> acceptAction [
	<magritteActionDescription>
	^ MAActionDescription new
		label: 'Accept';
		action: [ :aModel :aButton | 
			[ self repositoryModel addBaseline: self baseline.

			aButton
				inUIProcessDo: [ aButton dispatchEvent: BrDropdownHideWish new.
					aButton phlow fireUpdateWish ] ] on: Error do: #debug ];
		beCommitAction
]

{ #category : #accessing }
GtGitBaselineCreationForm >> asElement [
	^ (self asGtMagritteViewModel
		onElementCreated: [ :aFrame | 
			BlFocusFinder new
				direction: BlFocusSearchDirectionForward new;
				root: aFrame;
				referenceElement: nil;
				nextFocusDo: #requestFocus ifNone: [  ] ]) asElement
		padding: (BlInsets all: 5)
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
GtGitBaselineCreationForm >> initialize [
	baseline := ''
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
