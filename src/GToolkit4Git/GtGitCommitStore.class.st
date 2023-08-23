Class {
	#name : #GtGitCommitStore,
	#superclass : #FileSystemStore,
	#instVars : [
		'id',
		'repository',
		'entries',
		'gitFileReader'
	],
	#classVars : [
		'Registry'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #'instance creation' }
GtGitCommitStore class >> on: aCommitId inRepo: aGtIceGitRepository [
	^ self new
		commit: aCommitId;
		repository: aGtIceGitRepository;
		yourself
]

{ #category : #finalization }
GtGitCommitStore class >> register: anObject [
	^self registry add: anObject
]

{ #category : #accessing }
GtGitCommitStore class >> registry [
	^Registry ifNil: [Registry := WeakRegistry new]
]

{ #category : #accessing }
GtGitCommitStore >> basenameFromEntry: aNode [
	^ aNode path
]

{ #category : #accessing }
GtGitCommitStore >> basicCreationTimeOf: anEntry [ 
	^ DateAndTime now
]

{ #category : #accessing }
GtGitCommitStore >> basicEntry: directoryEntry path: aPath nodesDo: aBlock [
	| lines |
	lines := repository
			runGitWithArgs: {'ls-tree'.
					'--format=%(objectmode) %(objecttype) %(objectname) %(objectsize)%x09%(path)'.
					directoryEntry id}.
	lines do: [ :each | aBlock value: (GtGitFileEntry fromLine: each) ]
]

{ #category : #accessing }
GtGitCommitStore >> basicIsDirectory: aNode [
	^ aNode type = 'tree'
]

{ #category : #accessing }
GtGitCommitStore >> basicOpen: path writable: aBoolean [
	^ self
		nodeAt: path
		ifPresent: [ :entry | entry ]
		ifAbsent: [ aBoolean
				ifFalse: [ self signalFileDoesNotExist: path ]
				ifTrue: [ self shouldNotImplement ] ]
]

{ #category : #abstract }
GtGitCommitStore >> basicSizeOf: aNode [
	^ aNode size
]

{ #category : #'instance creation' }
GtGitCommitStore >> commit: aCommitId [
	id := aCommitId
]

{ #category : #accessing }
GtGitCommitStore >> delimiter [
	^ $/
]

{ #category : #accessing }
GtGitCommitStore >> entries [
	| entryList lines |
	entries ifNotNil: [ ^ entries ].
	entries := Dictionary new.
	lines := repository
			runGitWithArgs: {'ls-tree'.
					'-rt'.
					'--format=%(objectmode) %(objecttype) %(objectname) %(objectsize)%x09%(path)'.
					self treeIdFromCommit}.
	entryList := lines collect: [ :each | GtGitFileEntry fromLine: each ].
	entryList do: [ :each | entries at: (self basenameFromEntry: each) put: each ].
	^ entries
]

{ #category : #accessing }
GtGitCommitStore >> entryByPath: aString ifAbsent: aBlock [
	^ self entries at: aString ifAbsent: aBlock
]

{ #category : #public }
GtGitCommitStore >> entryFromNode: node path: path for: aFileSystem [
	^ aFileSystem referenceTo: path / node path
]

{ #category : #accessing }
GtGitCommitStore >> finalize [
	gitFileReader ifNotNil: [ :reader | reader stop ].
	super finalize
]

{ #category : #accessing }
GtGitCommitStore >> gitFileReader [
	^ gitFileReader
		ifNil: [ self class register: self.
			gitFileReader := GtGitCommitFileReader new
					workingDirectory: repository location;
					start ]
]

{ #category : #accessing }
GtGitCommitStore >> handleClass [
	^ GtGitFileHandle
]

{ #category : #accessing }
GtGitCommitStore >> nodeAt: anAbsolutePath ifPresent: aBlockClosure ifAbsent: aBlockClosure3 [
	anAbsolutePath isRoot ifTrue: [ ^ aBlockClosure value: self rootEntry ].
	^ aBlockClosure
		value: (self
				entryByPath: (anAbsolutePath relativeTo: Path root) pathString
				ifAbsent: [ ^ aBlockClosure3 value ])
]

{ #category : #accessing }
GtGitCommitStore >> readStreamOn: aGtGitFileHandle [
	^ self gitFileReader readStreamFor: aGtGitFileHandle entry id
]

{ #category : #accessing }
GtGitCommitStore >> repository [
	^ repository
]

{ #category : #'instance creation' }
GtGitCommitStore >> repository: aGtIceGitRepository [
	repository := aGtIceGitRepository
]

{ #category : #accessing }
GtGitCommitStore >> rootEntry [
	^ GtGitFileEntry new
		mode: '040000';
		type: 'tree';
		id: self treeIdFromCommit;
		size: 0;
		path: '.';
		yourself
]

{ #category : #accessing }
GtGitCommitStore >> treeIdFromCommit [
	^ (repository
		runGitWithArgs: {'show'.
				'-s'.
				'--format=format:%T'.
				id}) first
]
