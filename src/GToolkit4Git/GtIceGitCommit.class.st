Class {
	#name : #GtIceGitCommit,
	#superclass : #IceGitCommit,
	#instVars : [
		'fileSystem'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #accessing }
GtIceGitCommit >> entryByPath: aString ifAbsent: aBlock [
	| ref |
	ref := self fileSystem resolveString: aString.
	^ ref exists ifTrue: [ ref ] ifFalse: [ aBlock value ]
]

{ #category : #'accessing - file' }
GtIceGitCommit >> fileSystem [
	fileSystem
		ifNil: [ fileSystem := (FileSystem store: (GtGitCommitStore on: id inRepo: repository))
					root ].
	^ fileSystem
]

{ #category : #accessing }
GtIceGitCommit >> tags [
	^ self repository tagsFor: id
]
