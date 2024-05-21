Class {
	#name : #IceGitCliCommit,
	#superclass : #IceGitCommit,
	#instVars : [
		'project',
		'filesystem'
	],
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #ancestry }
IceGitCliCommit >> commonAncestorWithCommit: anIceGitCommit [
	| mergeBaseId |
	mergeBaseId := repository mergeBaseBetween: id and: anIceGitCommit id.
	^ mergeBaseId ifNotNil: [ self repository lookupCommit: mergeBaseId ]
]

{ #category : #accessing }
IceGitCliCommit >> entryByPath: aString ifAbsent: aBlock [
	| ref |
	ref := self fileSystem resolveString: aString.
	^ ref exists ifTrue: [ ref ] ifFalse: [ aBlock value ]
]

{ #category : #'accessing - file' }
IceGitCliCommit >> fileSystem [
	filesystem
		ifNil: [ filesystem := FileSystem store: (GitCliCommitStore on: id inRepo: repository) ].
	^ filesystem root
]

{ #category : #accessing }
IceGitCliCommit >> numberOfParents [
	^self ancestorIds size
]

{ #category : #accessing }
IceGitCliCommit >> project [
	^project ifNil: [project := super project]
]

{ #category : #accessing }
IceGitCliCommit >> tags [
	^ self repository tagsFor: id
]
