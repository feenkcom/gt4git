Class {
	#name : #GitCliCommitStore,
	#superclass : #FileSystemStore,
	#instVars : [
		'id',
		'repository',
		'entries'
	],
	#classVars : [
		'Registry'
	],
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #'instance creation' }
GitCliCommitStore class >> on: aCommitId inRepo: aGtIceGitRepository [
	^ self new
		commit: aCommitId;
		repository: aGtIceGitRepository;
		yourself
]

{ #category : #finalization }
GitCliCommitStore class >> register: anObject [
	^self registry add: anObject
]

{ #category : #accessing }
GitCliCommitStore class >> registry [
	^Registry ifNil: [Registry := WeakRegistry new]
]

{ #category : #accessing }
GitCliCommitStore >> basenameFromEntry: aNode [
	^ aNode path
]

{ #category : #accessing }
GitCliCommitStore >> basicCreationTimeOf: anEntry [ 
	^ DateAndTime now
]

{ #category : #accessing }
GitCliCommitStore >> basicEntry: directoryEntry path: aPath nodesDo: aBlock [
	| lines |
	lines := repository runGitWithArgs: {
		'ls-tree'.
		'--format=%(objectmode) %(objecttype) %(objectname) %(objectsize)%x09%(path)'.
		directoryEntry id }.
	lines do: [ :each | aBlock value: (GitCliFileEntry fromLine: each) ]
]

{ #category : #accessing }
GitCliCommitStore >> basicIsDirectory: aNode [
	^ aNode type = 'tree'
]

{ #category : #accessing }
GitCliCommitStore >> basicIsFile: aNode [
	^ aNode type = 'blob'
]

{ #category : #accessing }
GitCliCommitStore >> basicOpen: path writable: aBoolean [
	^ self
		nodeAt: path
		ifPresent: [ :entry | entry ]
		ifAbsent: [ aBoolean
				ifFalse: [ self signalFileDoesNotExist: path ]
				ifTrue: [ self shouldNotImplement ] ]
]

{ #category : #abstract }
GitCliCommitStore >> basicSizeOf: aNode [
	^ aNode size
]

{ #category : #'as yet unclassified' }
GitCliCommitStore >> binaryReadStreamOn: aGtGitFileHandle [
	^ (repository contentsOfFile: aGtGitFileHandle entry id) asUTF8Bytes readStream
]

{ #category : #'instance creation' }
GitCliCommitStore >> commit: aCommitId [
	id := aCommitId
]

{ #category : #accessing }
GitCliCommitStore >> delimiter [
	^ $/
]

{ #category : #accessing }
GitCliCommitStore >> entries [
	| entryList lines |
	entries ifNotNil: [ ^ entries ].
	entries := Dictionary new.
	lines := repository runGitWithArgs: {
		'ls-tree'.
		'-rt'.
		'--format=%(objectmode) %(objecttype) %(objectname) %(objectsize)%x09%(path)'.
		self treeIdFromCommit }.
	entryList := lines collect: [ :each | GitCliFileEntry fromLine: each ].
	entryList do: [ :each | entries at: (self basenameFromEntry: each) put: each ].
	^ entries
]

{ #category : #accessing }
GitCliCommitStore >> entryByPath: aString ifAbsent: aBlock [
	^ self entries at: aString ifAbsent: aBlock
]

{ #category : #public }
GitCliCommitStore >> entryFromNode: node path: path for: aFileSystem [
	^ aFileSystem referenceTo: path / node path
]

{ #category : #accessing }
GitCliCommitStore >> finalize [
	gitFileReader ifNotNil: [ :reader | reader terminate ].
	super finalize
]

{ #category : #printing }
GitCliCommitStore >> forReferencePrintOn: aStream [
	aStream nextPutAll: 'git://'
]

{ #category : #accessing }
GitCliCommitStore >> handleClass [
	^ GitCliFileHandle
]

{ #category : #accessing }
GitCliCommitStore >> nodeAt: anAbsolutePath ifPresent: aBlockClosure ifAbsent: aBlockClosure3 [
	anAbsolutePath isRoot ifTrue: [ ^ aBlockClosure value: self rootEntry ].
	^ aBlockClosure
		value: (self
				entryByPath: (anAbsolutePath relativeTo: Path root) pathString
				ifAbsent: [ ^ aBlockClosure3 value ])
]

{ #category : #accessing }
GitCliCommitStore >> readStreamOn: aGtGitFileHandle [
	^(repository contentsOfFile: aGtGitFileHandle entry id) readStream
]

{ #category : #accessing }
GitCliCommitStore >> repository [
	^ repository
]

{ #category : #'instance creation' }
GitCliCommitStore >> repository: aGtIceGitRepository [
	repository := aGtIceGitRepository
]

{ #category : #accessing }
GitCliCommitStore >> rootEntry [
	^ GitCliFileEntry new
		mode: '040000';
		type: 'tree';
		id: self treeIdFromCommit;
		size: 0;
		path: '.';
		yourself
]

{ #category : #accessing }
GitCliCommitStore >> treeIdFromCommit [
	^ (repository runGitWithArgs: {
		'show'.
		'-s'.
		'--format=format:%T'.
		id }) first
]
