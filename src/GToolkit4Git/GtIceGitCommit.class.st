Class {
	#name : #GtIceGitCommit,
	#superclass : #IceGitCommit,
	#instVars : [
		'project'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #ancestry }
GtIceGitCommit >> commonAncestorWithCommit: anIceGitCommit [
	| mergeBaseId |
	mergeBaseId := repository mergeBaseBetween: id and: anIceGitCommit id.
	^ mergeBaseId ifNotNil: [ self repository lookupCommit: mergeBaseId ]
]

{ #category : #accessing }
GtIceGitCommit >> entryByPath: aString ifAbsent: aBlock [
	| ref |
	ref := self fileSystem resolveString: aString.
	^ ref exists ifTrue: [ ref ] ifFalse: [ aBlock value ]
]

{ #category : #'accessing - file' }
GtIceGitCommit >> fileSystem [
	^(FileSystem store: (GtGitCommitStore on: id inRepo: repository))
					root
]

{ #category : #accessing }
GtIceGitCommit >> project [
	^project ifNil: [project := super project]
]

{ #category : #accessing }
GtIceGitCommit >> tags [
	^ self repository tagsFor: id
]
