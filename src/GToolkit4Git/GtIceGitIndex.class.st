Class {
	#name : #GtIceGitIndex,
	#superclass : #IceIndex,
	#instVars : [
		'modifiedFilePaths'
	],
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #adding }
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

{ #category : #removing }
GtIceGitIndex >> removeDirectoryFromIndex: aString [
	#TODO
]

{ #category : #storing }
GtIceGitIndex >> removeFileDefinition: anIceFileDefinition [ 
	
	(repository location resolve: anIceFileDefinition path)
		ensureDelete.

	self addPath: anIceFileDefinition path
]

{ #category : #removing }
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
