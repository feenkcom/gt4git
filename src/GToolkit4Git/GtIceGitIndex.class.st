Class {
	#name : #GtIceGitIndex,
	#superclass : #IceIndex,
	#instVars : [
		'modifiedFilePaths'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #'*GToolkit4Git' }
GtIceGitIndex >> addLepiterDatabase: aDatabaseDefinition [
	self addPath: (RelativePath 
		withAll: aDatabaseDefinition localRootRelativePath)
]

{ #category : #adding }
GtIceGitIndex >> addPackage: anIcePackageDefinition [
	| pathSegments |
	pathSegments := repository subdirectoryPath segments asOrderedCollection.
	pathSegments
		add: (repository writerClass directoryNameFor: anIcePackageDefinition).
	self addPath: (RelativePath withAll: pathSegments)
]

{ #category : #storing }
GtIceGitIndex >> addPath: aPath [
	modifiedFilePaths add: aPath
]

{ #category : #'API - commiting' }
GtIceGitIndex >> addToGitIndex [
	repository addFilesToIndex: modifiedFilePaths
]

{ #category : #'API - commiting' }
GtIceGitIndex >> commitWithMessage: message andParents: parentCommits [
	| signature indexTreeId commitId |
self halt. 
	self addToGitIndex.	"[ signature := self repositoryHandle defaultSignature ]
			on: LGit_GIT_ENOTFOUND, LGit_GIT_ERROR
			do: [ :e | IceGitUsernameOrEmailNotFound guessKind: e ifNot: [ e pass ] ]."
	indexTreeId := repository writeTreeAndReturnOid.
	commitId := repository
			writeCommit: indexTreeId
			message: message withUnixLineEndings utf8Encoded asString
			parents: parentCommits
			updateReference: repository head name
			author: signature
			committer: signature.
	^ commitId
]

{ #category : #accessing }
GtIceGitIndex >> includes: aRelativePath [
	^ modifiedFilePaths includes: aRelativePath
]

{ #category : #initialization }
GtIceGitIndex >> initialize [
	super initialize.
	modifiedFilePaths := Set new
]

{ #category : #testing }
GtIceGitIndex >> isEmpty [
	^ modifiedFilePaths isEmpty
]

{ #category : #'*GToolkit4Git' }
GtIceGitIndex >> removeDirectoryFromIndex: aString [
	#TODO
]

{ #category : #storing }
GtIceGitIndex >> removeFileDefinition: anIceFileDefinition [ 
	
	(repository location resolve: anIceFileDefinition path)
		ensureDelete.

	self addPath: anIceFileDefinition path
]

{ #category : #'*GToolkit4Git' }
GtIceGitIndex >> removeFileFromIndex: aString [
	#TODO
]

{ #category : #storing }
GtIceGitIndex >> storeFileDefinition: anIceFileDefinition [ 
	
	(repository location resolve: anIceFileDefinition path)
		ensureDelete;
		binaryWriteStreamDo: [ :writeStream |
			writeStream nextPutAll: anIceFileDefinition binaryContents ].

	self addPath: anIceFileDefinition path
]

{ #category : #storing }
GtIceGitIndex >> storeMCVersion: aMCVersion [ 

	| pathSegments |
	repository internalStoreVersion: aMCVersion.
	pathSegments := OrderedCollection new.
	repository subdirectory
		ifNotEmpty: [ :directory | pathSegments add: directory ].
	pathSegments add: (repository writerClass directoryNameFor: aMCVersion package).
	
	self addPath: (RelativePath withAll: pathSegments)
]

{ #category : #storing }
GtIceGitIndex >> storeVersion: aMCVersion [ 
	
	repository internalStoreVersion: aMCVersion
]

{ #category : #updating }
GtIceGitIndex >> updateDiskWorkingCopy: anIceDiff [
	anIceDiff tree
		accept:
			(IceGitWorkingCopyUpdateVisitor new
				repository: repository;
				index: self;
				diff: anIceDiff)
]
