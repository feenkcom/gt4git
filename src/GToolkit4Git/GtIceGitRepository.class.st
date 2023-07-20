Class {
	#name : #GtIceGitRepository,
	#superclass : #IceRepository,
	#instVars : [
		'location'
	],
	#classInstVars : [
		'spawnCount'
	],
	#category : #'GToolkit4Git-Libgit-replace'
}

{ #category : #'instance creation' }
GtIceGitRepository class >> fromLibGitRepository: aRepo [
	| repo |
	repo := self new
			location: aRepo location;
			name: aRepo name.
	repo workingCopy
		referenceCommit: (repo commitFromGitCommit: aRepo workingCopy referenceCommit id).
	repo workingCopy initializePackagesFromRepository.
	^ repo
]

{ #category : #actions }
GtIceGitRepository class >> incSpawnCount [
	self spawnCount: self spawnCount + 1
]

{ #category : #accessing }
GtIceGitRepository class >> spawnCount [
	^ spawnCount ifNil: [0]
]

{ #category : #accessing }
GtIceGitRepository class >> spawnCount: anObject [
	spawnCount := anObject
]

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

	^ GtIceGitLocalBranch named: aString inRepository: self
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

{ #category : #'*GToolkit4Git' }
GtIceGitRepository >> getStatusByFile [
	| res proc flagMap |
	flagMap := {$M -> 2.
			$T -> 16.
			$A -> 1.
			$D -> 4.
			$R -> 8.
			$? -> 128.
			$! -> 16384} asDictionary.
	res := Dictionary new.
	proc := self git
			arguments: {'status'.
					'--porcelain'}.
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ].
	proc stdout lines
		do: [ :each | 
			| status path |
			status := each first.
			path := each copyFrom: 4 to: each size.
			res at: path put: (LGitStatusEnum basicNew value: (flagMap at: status)) ].
	^ res
]

{ #category : #actions }
GtIceGitRepository >> git [
	self class incSpawnCount.
	^ GtSubprocessWithInMemoryOutput new
		command: 'git';
		workingDirectory: location
]

{ #category : #'*GToolkit4Git' }
GtIceGitRepository >> gtRepositoryDirectoryFor: aView [
	<gtView>
	
	| status |
	self isMissing ifTrue: [ ^ aView empty ].
	
	status := self getStatusByFile.
	^ (self repositoryDirectory gtTreeFor: aView)
		  title: 'Repository directory';
		  priority: 35;
		  column: 'Tracked' translated icon: [ :each | 
			  | relative |
			  relative := (each relativeTo: self repositoryDirectory)
				              pathString.
			  (status includesKey: relative)
				  ifTrue: [ 
					  (status at: relative) = LGitStatusEnum git_status_wt_new
						  ifTrue: [ BrGlamorousIcons close ]
						  ifFalse: [ BrGlamorousIcons accept ] ]
				  ifFalse: [ "exclude directories"
					  each isDirectory
						  ifTrue: [ BrGlamorousIcons empty ]
						  ifFalse: [ BrGlamorousIcons accept ] ] ] width: 50;
		  column: 'Actions' translated stencil: [ :each | 
			  | relative |
			  relative := each relativeTo: self repositoryDirectory.
			  ((status includesKey: relative pathString) and: [ 
					   (status at: relative pathString)
					   = LGitStatusEnum git_status_wt_new ])
				  ifTrue: [ 
					  BrButton new
						  aptitude: BrGlamorousButtonWithIconAptitude;
						  icon: BrGlamorousVectorIcons add;
						  label: 'Add ' , relative pathString;
						  beTinySize;
						  action: [ :_ | 
							  self index
								  addPath: relative;
								  addToGitIndex ] ]
				  ifFalse: [ 
					  BrButton new
						  aptitude: BrGlamorousButtonWithIconAptitude;
						  icon: BrGlamorousVectorIcons remove;
						  label: 'Remove ' , relative pathString;
						  beTinySize;
						  action: [ :_ | 
							  each isDirectory
								  ifTrue: [ self index removeDirectoryFromIndex: relative pathString ]
								  ifFalse: [ self index removeFileFromIndex: relative pathString ] ] ] ];
		  actionButtonIcon: BrGlamorousIcons go
		  tooltip: 'Open in OS'
		  action: [ WebBrowser openOn: self location fullName ]
]

{ #category : #accessing }
GtIceGitRepository >> gtStatusFor: aView [
	<gtView>
	
	self isMissing ifTrue: [ ^ aView empty ].
	^ aView columnedTree
		  title: 'File statuses';
		  priority: 2;
		  items: [ 
			  (self getStatusByFile associations groupedBy: [ :each | 
					   each value categoryName ]) associations sort: [ :a | 
					  a key = 'Untracked'
						  ifTrue: [ 0 ]
						  ifFalse: [ 
							  a key = 'Staged'
								  ifTrue: [ 2 ]
								  ifFalse: [ 1 ] ] ] descending ];
		  children: [ :each | 
			  each value isArray
				  ifTrue: [ each value ]
				  ifFalse: [ {  } ] ];
		  column: 'File' text: [ :each | each key ];
		  column: 'Status' text: [ :each | 
			  each value isArray
				  ifTrue: [ '' ]
				  ifFalse: [ each value statusName ] ];
		  expandAll
]

{ #category : #accessing }
GtIceGitRepository >> handleLibgitError: aBlock [
	"Just evaluate the block since we aren't libgit"
	aBlock value
]

{ #category : #'api - accessing' }
GtIceGitRepository >> head [
	| head proc lines ref |
	proc := self git
			arguments: {'show'.
					'-s'.
					'--format=tformat:%H%n%D'.
					'HEAD'}.
	proc runAndWait.
	proc isSuccess ifFalse: [ ^ IceGitUnbornBranch inRepository: self ].
	lines := proc stdout lines.
	head := lines at: 1.
	ref := ((lines at: 2) splitOn: ', ') first.
	^ (ref includesSubstring: '->')
		ifTrue: [ self basicNewBranchNamed: (ref splitOn: ' -> ') second ]
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

{ #category : #'API - branches' }
GtIceGitRepository >> localBranches [
	| branches proc |
	proc := self git
			arguments: {'branch'.
					'--format=%(refname:short)'}.
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ].
	branches := proc stdout lines.
	^ OrderedCollection
		new: 10
		streamContents: [ :stream | branches do: [ :br | stream nextPut: (self basicNewBranchNamed: br) ] ]
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

{ #category : #'API - branches' }
GtIceGitRepository >> lookupLocalBranch: branchName [
	| proc |
	proc := self git
			arguments: {'branch'.
					branchName.
					'--list'.
					'--format=%(objectname)'}.
	proc runAndWait.
	proc isSuccess ifFalse: [ self error: 'git error' ].
	^proc stdout lines first
]

{ #category : #'*GToolkit4Git' }
GtIceGitRepository >> makeSafe [
]

{ #category : #'as yet unclassified' }
GtIceGitRepository >> mcVersionFor: iceVersion [
	[ | commit |
	commit := iceVersion commit.
	^ (iceVersion commit readerClass on: commit iceVersion: iceVersion) version ]
		on: Error
		do: [ IceVersionDoesNotExist new
				version: iceVersion;
				signal ]
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
	id := proc stdout lines first.
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

{ #category : #'API - tags' }
GtIceGitRepository >> tagsFor: anId [
	| proc |
	proc := self git
			arguments: {'tag'.
					'--points-at'.
					anId}.
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
