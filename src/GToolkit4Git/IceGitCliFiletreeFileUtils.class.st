Class {
	#name : #IceGitCliFiletreeFileUtils,
	#superclass : #Object,
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #accessing }
IceGitCliFiletreeFileUtils class >> directoryExists: directory [
	^directory isDirectory
]

{ #category : #accessing }
IceGitCliFiletreeFileUtils class >> directoryFromEntry: classEntry [
	^classEntry asFileReference
]

{ #category : #accessing }
IceGitCliFiletreeFileUtils class >> directoryFromPath: aPath relativeTo: aDirectoryOrCommit [
	(aDirectoryOrCommit isKindOf: IceCommitish)
		ifTrue: [ ^ aDirectoryOrCommit fileSystem resolvePath: aPath ].
	^ aDirectoryOrCommit resolveString: aPath
]

{ #category : #accessing }
IceGitCliFiletreeFileUtils class >> readStreamFor: filePath in: aDirectory do: aBlock [
	(aDirectory resolveString: filePath)
		readStreamDo: [ :fileStream | 
			| stream |
			stream := ReadStream on: fileStream contents asString.
			stream reset.
			aBlock value: stream ]
]
