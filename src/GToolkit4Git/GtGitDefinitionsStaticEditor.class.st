Class {
	#name : #GtGitDefinitionsStaticEditor,
	#superclass : #GtGitDefinitionsEditor,
	#instVars : [
		'value',
		'action'
	],
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #accessing }
GtGitDefinitionsStaticEditor >> action: aBlock [
	action := aBlock
]

{ #category : #accessing }
GtGitDefinitionsStaticEditor >> getValue [
	^ value
]

{ #category : #accessing }
GtGitDefinitionsStaticEditor >> setValue: aString [
	action value: aString
]

{ #category : #accessing }
GtGitDefinitionsStaticEditor >> value: aString [
	value := aString
]
