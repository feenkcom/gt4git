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

	anElement when: GtPhlowToolObjectChangeWish do: [ :aWish |
		self object: aWish object ].
	
	^ aBlock value: anElement
]

{ #category : #accessing }
GtGitPhlowTool >> icon [
	^ BrGlamorousVectorIcons branching
]

{ #category : #'api - accessing' }
GtGitPhlowTool >> object: anObject [
	(anObject isKindOf: IceGitCliRepository) ifTrue: [ 
		self repository: (GtGitRepository fromIcebergRepository: anObject) ].

	(anObject isKindOf: GtGitRepository) ifTrue: [ 
		self repository: anObject ]
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
