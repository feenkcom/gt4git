Class {
	#name : #GtGitPhlowTool,
	#superclass : #GtPhlowTool,
	#instVars : [
		'repository'
	],
	#category : #'GToolkit4Git-Tools'
}

{ #category : #accessing }
GtGitPhlowTool >> asElementDo: aBlock [
	| anElement |
	anElement := GtGitElement new.

	self repository ifNotNil: [ :aRepository | anElement repository: aRepository ].

	^ aBlock value: anElement
]

{ #category : #accessing }
GtGitPhlowTool >> icon [
	^ BrGlamorousVectorIcons branching
]

{ #category : #accessing }
GtGitPhlowTool >> repository [
	^ repository
]

{ #category : #accessing }
GtGitPhlowTool >> repository: anObject [
	repository := anObject
]

{ #category : #accessing }
GtGitPhlowTool >> tabLook [
	^ BrGlamorousTabSwitcherWithIconAptitude
]
