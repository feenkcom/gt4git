Class {
	#name : #GtGitRepositoryLocationDoesntExist,
	#superclass : #GtGitError,
	#instVars : [
		'fileReference',
		'repository'
	],
	#category : #'GToolkit4Git-Libgit-CLI-Support'
}

{ #category : #accessing }
GtGitRepositoryLocationDoesntExist >> fileReference [
	^ fileReference
]

{ #category : #accessing }
GtGitRepositoryLocationDoesntExist >> fileReference: anObject [
	fileReference := anObject
]

{ #category : #accessing }
GtGitRepositoryLocationDoesntExist >> repository [
	^ repository
]

{ #category : #accessing }
GtGitRepositoryLocationDoesntExist >> repository: anObject [
	repository := anObject
]
