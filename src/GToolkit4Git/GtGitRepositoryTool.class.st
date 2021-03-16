Class {
	#name : #GtGitRepositoryTool,
	#superclass : #GtPhlowTool,
	#instVars : [
		'repositoryViewModel'
	],
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #'api - converting' }
GtGitRepositoryTool >> asElementDo: aOneArgBlock [
	"Create a tool element and execute the block."
	| anElement |
	anElement := GtGitRepositoryElement new
		margin: (BlInsets all: 10);
		repositoryViewModel: self repositoryViewModel.
		
	^ aOneArgBlock cull: anElement
]

{ #category : #'api - accessing' }
GtGitRepositoryTool >> repositoryViewModel [
	^ repositoryViewModel
]

{ #category : #'api - accessing' }
GtGitRepositoryTool >> repositoryViewModel: anObject [
	repositoryViewModel := anObject
]
