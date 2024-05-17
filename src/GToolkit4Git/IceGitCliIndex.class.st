Class {
	#name : #IceGitCliIndex,
	#superclass : #IceIndex,
	#instVars : [
		'modifiedFilePaths'
	],
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #adding }
IceGitCliIndex >> addLepiterDatabase: aDatabaseDefinition [
	self addPath: (RelativePath 
		withAll: aDatabaseDefinition localRootRelativePath)
]

{ #category : #adding }
IceGitCliIndex >> addPackage: anIcePackageDefinition [
	| pathSegments |
	pathSegments := repository subdirectoryPath segments asOrderedCollection.
	pathSegments
		add: (repository writerClass directoryNameFor: anIcePackageDefinition).
	self addPath: (RelativePath withAll: pathSegments)
]

{ #category : #storing }
IceGitCliIndex >> addPath: aPath [
	modifiedFilePaths add: aPath
]

{ #category : #'API - commiting' }
IceGitCliIndex >> addToGitIndex [
	repository addFilesToIndex: modifiedFilePaths
]

{ #category : #'API - commiting' }
IceGitCliIndex >> commitWithMessage: message andParents: parentCommits [
	| signature indexTreeId commitId |
	self addToGitIndex.
	indexTreeId := repository writeTreeAndReturnOid.
	commitId := repository
			writeCommit: indexTreeId
			message: message withUnixLineEndings utf8Encoded asString
			parents: parentCommits
			updateReference: repository head name
			author: signature
			committer: signature.
	^ repository commitFromGitCommit: commitId
]

{ #category : #accessing }
IceGitCliIndex >> includes: aRelativePath [
	^ modifiedFilePaths includes: aRelativePath
]

{ #category : #initialization }
IceGitCliIndex >> initialize [
	super initialize.
	modifiedFilePaths := Set new
]

{ #category : #testing }
IceGitCliIndex >> isEmpty [
	^ modifiedFilePaths isEmpty
]

{ #category : #removing }
IceGitCliIndex >> removeDirectoryFromIndex: aString [
	#TODO
]

{ #category : #storing }
IceGitCliIndex >> removeFileDefinition: anIceFileDefinition [ 
	
	(repository location resolve: anIceFileDefinition path)
		ensureDelete.

	self addPath: anIceFileDefinition path
]

{ #category : #removing }
IceGitCliIndex >> removeFileFromIndex: aString [
	#TODO
]

{ #category : #storing }
IceGitCliIndex >> storeFileDefinition: anIceFileDefinition [ 
	
	(repository location resolve: anIceFileDefinition path)
		ensureDelete;
		binaryWriteStreamDo: [ :writeStream |
			writeStream nextPutAll: anIceFileDefinition binaryContents ].

	self addPath: anIceFileDefinition path
]

{ #category : #storing }
IceGitCliIndex >> storeMCVersion: aMCVersion [ 

	| pathSegments |
	repository internalStoreVersion: aMCVersion.
	pathSegments := OrderedCollection new.
	repository subdirectory
		ifNotEmpty: [ :directory | pathSegments add: directory ].
	pathSegments add: (repository writerClass directoryNameFor: aMCVersion package).
	
	self addPath: (RelativePath withAll: pathSegments)
]

{ #category : #storing }
IceGitCliIndex >> storeVersion: aMCVersion [ 
	
	repository internalStoreVersion: aMCVersion
]

{ #category : #updating }
IceGitCliIndex >> updateDiskWorkingCopy: anIceDiff [
	anIceDiff tree
		accept:
			(IceGitWorkingCopyUpdateVisitor new
				repository: repository;
				index: self;
				diff: anIceDiff)
]
