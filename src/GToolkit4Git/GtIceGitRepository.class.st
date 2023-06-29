Class {
	#name : #GtIceGitRepository,
	#superclass : #IceRepository,
	#instVars : [
		'location'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #accessing }
GtIceGitRepository >> addFilesToIndex: aCollection [
	| proc |
	proc := self git.
	proc arguments: {'add'}.
	proc
		arguments: (aCollection
				collect: [ :each | 
					self assert: each asFileReference isRelative.
					each asFileReference path pathString ]).
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ]
]

{ #category : #'API - branches' }
GtIceGitRepository >> basicNewBranchNamed: aString [ 

	^ IceGitLocalBranch named: aString inRepository: self
]

{ #category : #'API - branches' }
GtIceGitRepository >> basicNewRemoteBranchNamed: aString [ 

	^ IceGitRemoteBranch named: aString inRepository: self
]

{ #category : #'private - changes' }
GtIceGitRepository >> changedFilesBetween: aCommitish and: otherCommitish [
	"Answer a list of files that changed between two commits"
	| proc |
	proc := self git
			arguments: {'diff'.
					'--name-only'.
					aCommitish id .
					otherCommitish id}.
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ].
	^proc stdout lines
]

{ #category : #'api - registry' }
GtIceGitRepository >> checkForRegistryConflicts [
	
	"If the repository has no location, do not check for conflicts."
	self location ifNil: [ ^ self ].
	
	self class registry 
		detect: [ :repo | repo location = self location ]
		ifFound: [ :repo | self origin = repo origin
			ifTrue: [ 
				IceDuplicatedRepository signal: 
					('You already have an Iceberg repository 
at {1} 
and with the same origin URL. 

If you really whant create another one, 
please locate it in a different directory.'
					 format: {self location pathString}) ]
			ifFalse: [
				IceDuplicatedRepository signal: 
					('You already have an Iceberg repository at 
{1} 
but with a different origin URL.

You provided {2} 
and the original repository''s url is {3}.'
					 format: {self location. self origin. repo origin}) ]].
]

{ #category : #'private - commits' }
GtIceGitRepository >> commitFromGitCommit: commitIdString [
	| proc lines |
	proc := self git
			arguments: {'show'.
					'-s'.
					'--format=tformat:%H%n%an%n%at%n%P%n%n%B'.
					commitIdString}.
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ].
	lines := proc stdout lines.
	^ self iceGitCommitFromLines: lines
]

{ #category : #'private - commits' }
GtIceGitRepository >> commitsFromIds: idCollection [
	"Note: This code expects the collection to consist of sequence of commits"

	| proc lines commitLines |
	proc := self git
			arguments: {'show'.
					'-s'.
					'--format=format:%H%n%an%n%at%n%P%n%n%B%n@@@'.
					idCollection last , '..' , idCollection first}.
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ].
	lines := proc stdout lines.
	commitLines := lines splitOn: [ :each | each = '@@@' ].
	commitLines removeLast.
	^ commitLines collect: [ :each | self iceGitCommitFromLines: each ]
]

{ #category : #actions }
GtIceGitRepository >> git [
	^ GtSubprocessWithInMemoryOutput new
		command: 'git';
		workingDirectory: location
]

{ #category : #accessing }
GtIceGitRepository >> handleLibgitError: aBlock [
	"Just evaluate the block since we aren't libgit"
	aBlock value
]

{ #category : #'api - accessing' }
GtIceGitRepository >> head [
	| head proc lines |
	proc := self git
			arguments: {'show'.
					'--format=tformat:%H%n%D'.
					'HEAD'}.
	proc runAndWait.
	proc isSuccess ifFalse: [ ^ IceGitUnbornBranch inRepository: self ].
	lines := proc stdout lines.
	head := lines at: 1.
	^ ((lines at: 2) includesSubstring: '->')
		ifTrue: [ self basicNewBranchNamed: ((lines at: 2) splitOn: ' -> ') second ]
		ifFalse: [ self commitFromGitCommit: head ]
]

{ #category : #'private - commits' }
GtIceGitRepository >> iceGitCommitFromLines: lines [
	| author datetime message id parents |
	id := lines at: 1.
	author := lines at: 2.
	datetime := DateAndTime fromUnixTime: (lines at: 3) asInteger.
	parents := (lines at: 4) splitOn: ' '.
	message := String
			streamContents: [ :str | 
				6
					to: lines size
					do: [ :i | 
						str
							nextPutAll: (lines at: i);
							cr ] ].
	^ GtIceGitCommit new
		id: id;
		author: author;
		datetime: datetime;
		ancestorIds: parents;
		comment: message;
		repository: self;
		yourself
]

{ #category : #actions }
GtIceGitRepository >> initBare: isBareRepository [
	| proc |
	proc := self git arguments: {'init'}.
	isBareRepository ifTrue: [ proc addArgument: '--bare' ].
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ]
]

{ #category : #testing }
GtIceGitRepository >> isMissing [
	^ self repositoryDirectory isNil 
		or: [ self repositoryDirectory exists not ]
]

{ #category : #accessing }
GtIceGitRepository >> location [
	^ location
]

{ #category : #actions }
GtIceGitRepository >> location: aLocation [
	location := aLocation 
]

{ #category : #'API - commits' }
GtIceGitRepository >> lookupCommit: commitId ifAbsent: aBlock [
	^ [ self commitFromGitCommit: commitId ] onErrorDo: [ aBlock value ]
]

{ #category : #'*GToolkit4Git' }
GtIceGitRepository >> makeSafe [
]

{ #category : #'API - accessing' }
GtIceGitRepository >> newCommitWalk [
	^ GtIceCommitWalk forRepository: self
]

{ #category : #'private - changes' }
GtIceGitRepository >> newIndex [
	^ GtIceGitIndex on: self
]

{ #category : #accessing }
GtIceGitRepository >> newNoCommit [
	^ IceNoCommit repository: self
]

{ #category : #'API - remotes' }
GtIceGitRepository >> origin [
	
	^ self
		remoteNamed: 'origin'
		ifAbsent: [
			IceUndefinedRemote new
				name: 'origin';
				yourself ]
]

{ #category : #'private - tags' }
GtIceGitRepository >> peelTag: anIceTag [
	| proc id |
	proc := self git
			arguments: {'show'.
					'-s'.
					'--format=tformat:%H'.
					anIceTag name}.
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ].
	id := proc stdout.
	^ self lookupCommit: id
]

{ #category : #'API - project' }
GtIceGitRepository >> project [
	^ self workingCopy project
]

{ #category : #accessing }
GtIceGitRepository >> properties [
	^ self workingCopy repositoryProperties
]

{ #category : #'API - remotes' }
GtIceGitRepository >> remoteNamed: aName ifAbsent: aBlockClosure [
	| gitRemote proc |
	proc := self git
			arguments: {'remote'.
					'get-url'.
					aName}.
	proc runAndWait.
	proc isSuccess ifFalse: [ ^ aBlockClosure value ].
	gitRemote := proc stdout trimBoth.
	^ (IceGitRemote name: aName url: gitRemote)
		localRepository: self;
		yourself
]

{ #category : #'API - branches' }
GtIceGitRepository >> remoteTrackedBranches [
	| branches proc |
	proc := self git
			arguments: {'branch'.
					'--remote'}.
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ].
	branches := proc stdout lines collect: #trimBoth.
	^ branches collect: [ :each | self basicNewRemoteBranchNamed: each ]
]

{ #category : #'API - accessing' }
GtIceGitRepository >> repositoryDirectory [
	^ self location
]

{ #category : #'API - commits' }
GtIceGitRepository >> revList [
	| revs proc |
	proc := self git
			arguments: {'rev-list'}.
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ].
	revs := proc stdout lines collect: #trimBoth.
	^revs
]

{ #category : #'API - commits' }
GtIceGitRepository >> revListForBranch: aBranch [
	| revs proc |
	proc := self git
			arguments: {'rev-list'.
					aBranch name}.
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ].
	revs := proc stdout lines collect: #trimBoth.
	^ revs
]

{ #category : #'API - accessing' }
GtIceGitRepository >> subdirectory [
	^ self project sourceDirectory
]

{ #category : #'API - accessing' }
GtIceGitRepository >> subdirectoryPath [
	
	"API compatible both with Pharo6 and Pharo7.
	This could be replaced by the Pharo7 API
	
	RelativePath with: self subdirectory
	"
	^ RelativePath withAll: (RelativePath canonicalizeElements: ($/ split: self subdirectory))
]

{ #category : #accessing }
GtIceGitRepository >> subdirectoryReference [
	^ self location resolve: self subdirectoryPath
]

{ #category : #'API - tags' }
GtIceGitRepository >> tags [
	| proc |
	proc := self git arguments: {'tag'}.
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ].
	^ proc stdout lines collect: [ :each | IceTag named: each inRepository: self ]
]

{ #category : #accessing }
GtIceGitRepository >> writeCommit: indexTreeId message: message parents: parentCommits updateReference: ref author: author committer: committer [
	| proc |
	proc := self git
			arguments: {'commit-tree'.
					indexTreeId.
					'-m'.
					message}.
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ].
	^ proc stdout trimBoth
]

{ #category : #accessing }
GtIceGitRepository >> writeTree: indexTreeId message: message parents: parentCommits updateReference: ref author: author committer: committer [
	
]

{ #category : #accessing }
GtIceGitRepository >> writeTreeAndReturnOid [
	| proc |
	proc := self git arguments: {'write-tree'}.
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ].
	^ proc stdout trimBoth
]
