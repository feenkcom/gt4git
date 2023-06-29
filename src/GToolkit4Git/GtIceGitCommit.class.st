Class {
	#name : #GtIceGitCommit,
	#superclass : #IceGitCommit,
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #'accessing - file' }
GtIceGitCommit >> fileSystem [
	^ (FileSystem store: (GtGitCommitStore on: id inRepo: repository)) root
]
