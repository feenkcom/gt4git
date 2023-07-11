Class {
	#name : #GtIceGitCommit,
	#superclass : #IceGitCommit,
	#instVars : [
		'fileSystem'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #'accessing - file' }
GtIceGitCommit >> fileSystem [
	fileSystem
		ifNil: [ fileSystem := (FileSystem store: (GtGitCommitStore on: id inRepo: repository))
					root ].
	^ fileSystem
]
