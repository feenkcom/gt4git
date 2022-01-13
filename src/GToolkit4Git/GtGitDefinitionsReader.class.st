Class {
	#name : #GtGitDefinitionsReader,
	#superclass : #GtGitDefinitionsViewer,
	#instVars : [
		'repository',
		'getSelector'
	],
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #accessing }
GtGitDefinitionsReader >> create [
	| theInitialName aLabel |
	
	theInitialName := self getValue.

	aLabel := BrEditor new
		beReadOnlyWithoutSelection;
		fitContent;
		aptitude: lookStencil create;
		margin: self margin;
		focusability: BlFocusability none;
		text: theInitialName.
		
	^ aLabel
]

{ #category : #accessing }
GtGitDefinitionsReader >> getSelector: aSymbol [
	getSelector := aSymbol
]

{ #category : #accessing }
GtGitDefinitionsReader >> getValue [
	^  [ repository perform: getSelector withArguments: {} ] on: Error do: [ '' ]
]

{ #category : #accessing }
GtGitDefinitionsReader >> repository: aRepository [
	repository := aRepository
]
