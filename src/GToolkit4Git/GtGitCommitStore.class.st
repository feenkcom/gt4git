Class {
	#name : #GtGitCommitStore,
	#superclass : #FileSystemStore,
	#instVars : [
		'id',
		'repository',
		'entries'
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

{ #category : #accessing }
GtGitCommitStore >> basenameFromEntry: aNode [
	^ (aNode splitOn: Character tab) last
]

{ #category : #accessing }
GtGitCommitStore >> basicEntry: directoryEntry path: aPath nodesDo: aBlock [
	| dirid proc |
	dirid := (directoryEntry splitOn: $ ) third copyUpTo: Character tab.
	proc := repository git
			arguments: {'ls-tree'.
					dirid}.
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ].
	proc stdout lines do: [ :each | aBlock value: each ]
]

{ #category : #accessing }
GtGitCommitStore >> basicIsDirectory: aNode [
	^ (aNode splitOn: $ ) second = 'tree'
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
	| proc |
	entries ifNotNil: [ ^ entries ].
	entries := Dictionary new.
	proc := repository git
			arguments: {'ls-tree'.
					'-rt'.
					self treeIdFromCommit}.
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ].
	proc stdout lines
		do: [ :each | entries at: (self basenameFromEntry: each) put: each ].
	^ entries
]

{ #category : #accessing }
GtGitCommitStore >> entryByPath: aString ifAbsent: aBlock [
	^ self entries at: aString ifAbsent: aBlock
]

{ #category : #accessing }
GtGitCommitStore >> handleClass [
	^ GtGitFileHandle
]

{ #category : #accessing }
GtGitCommitStore >> nodeAt: anAbsolutePath ifPresent: aBlockClosure ifAbsent: aBlockClosure3 [
	anAbsolutePath isRoot ifTrue: [ ^ aBlockClosure value: self treeIdFromCommit ].
	^ aBlockClosure
		value: (self
				entryByPath: (anAbsolutePath relativeTo: Path root) pathString
				ifAbsent: [ ^ aBlockClosure3 value ])
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
GtGitCommitStore >> treeIdFromCommit [
	| proc |
	proc := repository git
			arguments: {'show'.
					'-s'.
					'--format=format:%T'.
					id}.
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ].
	^ proc stdout
]
