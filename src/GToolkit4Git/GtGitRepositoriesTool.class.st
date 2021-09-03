Class {
	#name : 'GtGitRepositoriesTool',
	#superclass : 'GtPhlowTool',
	#instVars : [
		'repositoriesViewModel'
	],
	#category : 'GToolkit4Git-UI - Element'
}

{ #category : 'api - converting' }
GtGitRepositoriesTool >> asElementDo: aOneArgBlock [
	"Create a tool element and execute the block."
	| anElement |
	anElement := GtGitRepositoriesElement new
		margin: (BlInsets all: 10).
	
	self repositoriesViewModel ifNotNil: [ 
		anElement repositoriesViewModel: self repositoriesViewModel ].
		
	^ aOneArgBlock cull: anElement
]

{ #category : 'api - accessing' }
GtGitRepositoriesTool >> repositoriesViewModel [
	^ repositoriesViewModel
]

{ #category : 'api - accessing' }
GtGitRepositoriesTool >> repositoriesViewModel: anObject [
	repositoriesViewModel := anObject
]
