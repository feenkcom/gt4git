Class {
	#name : #GtGitRepositoryGroup,
	#superclass : #Object,
	#instVars : [
		'repos'
	],
	#category : 'GToolkit4Git-Inspector Integration'
}

{ #category : #accessing }
GtGitRepositoryGroup >> addRepository: aRepo [
	repos add: aRepo
]

{ #category : #accessing }
GtGitRepositoryGroup >> repositories [
	^ repos
]

{ #category : #accessing }
GtGitRepositoryGroup >> repositories: aListOfRepositories [
	repos := aListOfRepositories copyFrom: 1 to: aListOfRepositories size.
]
