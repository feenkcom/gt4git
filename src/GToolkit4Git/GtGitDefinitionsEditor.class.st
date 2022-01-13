Class {
	#name : #GtGitDefinitionsEditor,
	#superclass : #GtGitDefinitionsViewer,
	#instVars : [
		'getSelector',
		'setSelector',
		'repository',
		'completions'
	],
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #accessing }
GtGitDefinitionsEditor >> completions: aSymbol [
	completions := aSymbol
]

{ #category : #accessing }
GtGitDefinitionsEditor >> create [
	| theInitialName anEditableLabel |
	
	theInitialName := self getValue.

	anEditableLabel := BrEditableLabel new
		aptitude: lookStencil create;
		margin: self margin;
		text: theInitialName;
		when: BrEditorAcceptWish do: [ :aWish |			
			repository perform: setSelector withEnoughArguments: { aWish text asString }].
			
	completions ifNotNil: [
		| strategy |
		strategy := GtStringsCompletionStrategy new.
		strategy completions: (GtPrefixTree withAll: completions).
		(GtCompletionController
			on: anEditableLabel
			strategy: strategy) install
	].
	
	^ anEditableLabel
]

{ #category : #accessing }
GtGitDefinitionsEditor >> getSelector: aSymbol [
	getSelector := aSymbol
]

{ #category : #accessing }
GtGitDefinitionsEditor >> getValue [
	^ repository perform: getSelector withArguments: {}.
]

{ #category : #accessing }
GtGitDefinitionsEditor >> repository: aRepository [
	repository := aRepository
]

{ #category : #accessing }
GtGitDefinitionsEditor >> setSelector: aSymbol [
	setSelector := aSymbol
]

{ #category : #accessing }
GtGitDefinitionsEditor >> setValue: aString [
	repository perform: setSelector withEnoughArguments: { aString }
]
