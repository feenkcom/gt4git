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
	| builder exitValue |
	builder := self gitProcess.
	builder arg: 'add'.
	builder
		args: (aCollection
				collect: [ :each | 
					self assert: each asFileReference isRelative.
					each asFileReference path pathString ]).
	exitValue := builder status.
	exitValue isSuccess ifFalse: [ self error: 'git error' ]
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

{ #category : #actions }
GtIceGitRepository >> git [
	^ '/opt/local/bin/git'
]

{ #category : #accessing }
GtIceGitRepository >> gitProcess [
	^ GtExternalProcessBuilder new
		workingDirectory: location;
		command: self git
]

{ #category : #accessing }
GtIceGitRepository >> handleLibgitError: aBlock [
	"Just evaluate the block since we aren't libgit"
	aBlock value
]

{ #category : #'api - accessing' }
GtIceGitRepository >> head [
	| head |
	head := (self gitProcess
			args: {'show-ref'.
					'HEAD'};
			output) stdout.
	self halt.
	^ head isBranch
		ifTrue: [ self basicNewBranchNamed: head name ]
		ifFalse: [ head object asIcebergObjectInRepository: self ]
]

{ #category : #actions }
GtIceGitRepository >> initBare: isBareRepository [
	| builder exitValue |
	builder := self gitProcess arg: 'init'.
	isBareRepository ifTrue: [ builder arg: '--bare' ].
	exitValue := builder status.
	exitValue isSuccess ifFalse: [ self error: 'git error' ]
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

{ #category : #'*GToolkit4Git' }
GtIceGitRepository >> makeSafe [
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

{ #category : #accessing }
GtIceGitRepository >> properties [
	^ self workingCopy repositoryProperties
]

{ #category : #'API - remotes' }
GtIceGitRepository >> remoteNamed: aName ifAbsent: aBlockClosure [
	| gitRemote builder |
	builder := self gitProcess
			args: {'remote'.
					'get-url'.
					aName}.
	gitRemote := builder output stdout trimBoth.
	(gitRemote isEmpty
		or: [ (gitRemote beginsWith: 'error:') or: [ gitRemote beginsWith: 'fatal:' ] ])
		ifTrue: [ ^ aBlockClosure value ].
	^ (IceGitRemote name: aName url: gitRemote)
		localRepository: self;
		yourself
]

{ #category : #'API - accessing' }
GtIceGitRepository >> repositoryDirectory [
	^ self location
]

{ #category : #accessing }
GtIceGitRepository >> writeCommit: indexTreeId message: message parents: parentCommits updateReference: ref author: author committer: committer [
	| output |
	output := self gitProcess
			args: { 'commit-tree' . indexTreeId .
					 '-m' . message .
					 };
			output.
	^ output stdout trimBoth
]

{ #category : #accessing }
GtIceGitRepository >> writeTree: indexTreeId message: message parents: parentCommits updateReference: ref author: author committer: committer [
	
]

{ #category : #accessing }
GtIceGitRepository >> writeTreeAndReturnOid [
	| output |
	output := self gitProcess
			arg: 'write-tree';
			output.
	^ output stdout trimBoth
]
