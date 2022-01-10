Class {
	#name : #GtGitDefinitionsStaticReader,
	#superclass : #GtGitDefinitionsReader,
	#instVars : [
		'value'
	],
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #accessing }
GtGitDefinitionsStaticReader >> getValue [
	^ value
]

{ #category : #accessing }
GtGitDefinitionsStaticReader >> value: aValue [
	value := aValue
]
