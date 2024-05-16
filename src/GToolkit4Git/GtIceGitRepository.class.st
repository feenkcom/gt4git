"
I really should add class comments
"
Class {
	#name : #GtIceGitRepository,
	#superclass : #IceRepository,
	#instVars : [
		'location',
		'head',
		'remoteMap',
		'branchMap',
		'revListMap'
	],
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #'instance creation' }
GtIceGitRepository class >> fromLibGitRepository: aRepo [
	| repo |
	repo := self new
			location: aRepo location;
			name: aRepo name.
	aRepo isMissing ifTrue: [ ^ repo ].
	repo workingCopy
		referenceCommit: (repo commitFromGitCommit: aRepo workingCopy referenceCommit id).
	repo workingCopy initializePackagesFromRepository.
	^ repo
]

{ #category : #'gt extensions' }
GtIceGitRepository class >> gtViewGitCallsIn: composite [
	<gtClassView>
	
	^ composite columnedList
		title: 'Git calls';
		priority: 30;
		items: [ 
			(#runGitWithArgs: gtReferences & #gtViewGitCallsIn: gtImplementors not) 
				contents sort: #selector ascending ];
		column: 'Selector' text: [ :each | each selector ];
		column: 'Class' text: [ :each | each methodClass ]
]

{ #category : #'instance creation' }
GtIceGitRepository class >> on: aFileReference [
	^ self basicNew
		initialize;
		initializeOn: aFileReference
]

{ #category : #accessing }
GtIceGitRepository >> addFilesToIndex: aCollection [
	| args |
	args := { 'add' } asOrderedCollection.
	args
		addAll: (aCollection
				collect: [ :each | 
					self assert: each asFileReference isRelative.
					each asFileReference path pathString ]).
	self runGitWithArgs: args
]

{ #category : #'API - branches' }
GtIceGitRepository >> allBranches [
	^ self localBranches , self remoteTrackedBranches
]

{ #category : #'API - accessing' }
GtIceGitRepository >> basicCodeDirectory [
	^ self subdirectory isEmptyOrNil
		ifTrue: [ self repositoryDirectory ]
		ifFalse: [ self repositoryDirectory / self subdirectory ]
]

{ #category : #'API - branches' }
GtIceGitRepository >> basicNewBranchNamed: aString [ 

	^ GtIceGitLocalBranch named: aString inRepository: self
]

{ #category : #'API - branches' }
GtIceGitRepository >> basicNewRemoteBranchNamed: aString [ 

	^ GtIceGitRemoteBranch named: aString inRepository: self
]

{ #category : #'API - branches' }
GtIceGitRepository >> branchNamed: aString ifPresent: presentBlock ifAbsent: absentBlock [
	| found |
	found := self lookupLocalBranch: aString ifAbsent: [ nil ].
	^ found
		ifNil: absentBlock
		ifNotNil: [ presentBlock value: (self basicNewBranchNamed: aString) ]
]

{ #category : #'private - changes' }
GtIceGitRepository >> changedFilesBetween: aCommitish and: otherCommitish [
	"Answer a list of files that changed between two commits"

	^ self runGitWithArgs: {
		'diff'.
		'--name-only'.
		aCommitish id.
		otherCommitish id }
]

{ #category : #'API - registry' }
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

{ #category : #accessing }
GtIceGitRepository >> clearCaches [
	head := nil.
	branchMap := Dictionary new
]

{ #category : #actions }
GtIceGitRepository >> clone: aString [
	self runGitWithArgs: {
		'clone'.
		aString . 
		'.' }
]

{ #category : #'API - accessing' }
GtIceGitRepository >> codeDirectory [
	"Code repository might have been deleted or image might have been moved."
	self repositoryDirectory exists
		ifTrue: [ ^ self basicCodeDirectory ]
		ifFalse: [ IceLocalRepositoryMissing signalFor: self ]
]

{ #category : #'private - commits' }
GtIceGitRepository >> commitFromGitCommit: commitIdString [
	| lines |
	lines := self runGitWithArgs: {
		'show'.
		'-s'.
		'--format=tformat:%H%n%an%n%at%n%P%n%n%B'.
		commitIdString }.
	^ self iceGitCommitFromLines: lines
]

{ #category : #'private - commits' }
GtIceGitRepository >> commitsFromIds: idCollection [
	| lines commitLines range commits |
	idCollection isEmpty ifTrue: [ ^ #() ].
	range := idCollection size = 1
			ifTrue: [ idCollection first ]
			ifFalse: [ idCollection last , '..' , idCollection first ].
	lines := self runGitWithArgs: {
		'show'.
		'-s'.
		'--format=format:%H%n%an%n%at%n%P%n%n%B%n@@@'.
		range }.
	commitLines := lines splitOn: [ :each | each = '@@@' ].
	commitLines removeLast.
	commits := commitLines collect: [ :each | self iceGitCommitFromLines: each ].
	"the last commit from the range query above is not resolved, fetch it individually"
	idCollection size > 1
		ifTrue: [ commits := commits , (self commitsFromIds: { idCollection last }) ].
	^ commits
]

{ #category : #accessing }
GtIceGitRepository >> configureUpstreamIfNecessary [
	#TODO
]

{ #category : #accessing }
GtIceGitRepository >> directoryNameForPackage: package [

	^ (self writerClass 
		directoryNameFor: package)
		asString
]

{ #category : #accessing }
GtIceGitRepository >> directoryPathStringForPackage: aMCPackage [ 

	^ self subdirectory isEmptyOrNil 
		ifTrue: [ self directoryNameForPackage: aMCPackage ]
		ifFalse: [ self subdirectory, '/',  (self directoryNameForPackage: aMCPackage) ]
]

{ #category : #'API - remotes' }
GtIceGitRepository >> fetch [
	"Fetch all commits and branches from all remotes"

	self runGitWithArgs: {
		'fetch'.
		'--all' }
]

{ #category : #'API - accessing' }
GtIceGitRepository >> getDeltasForFullDiff [
	#TODO.
	^ #()
]

{ #category : #'API - accessing' }
GtIceGitRepository >> getStatusByFile [
	| res flagMap lines |
	flagMap := { $M -> 2.
			$T -> 16.
			$A -> 1.
			$D -> 4.
			$R -> 8.
			$? -> 128.
			$! -> 16384 } asDictionary.
	res := Dictionary new.
	lines := self runGitWithArgs: {
		'status'.
		'--porcelain' }.
	lines
		do: [ :each | 
			| status path |
			status := each first.
			path := each copyFrom: 4 to: each size.
			res at: path put: (LGitStatusEnum basicNew value: (flagMap at: status)) ].
	^ res
]

{ #category : #actions }
GtIceGitRepository >> git [
	^ GtExternalProcessBuilder new
		command: 'git';
		workingDirectory: location
]

{ #category : #'gt extensions' }
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

{ #category : #'gt extensions' }
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

{ #category : #'API - accessing' }
GtIceGitRepository >> head [
	| headRef lines ref |
	head notNil ifTrue: [ ^ head ].
	lines := [ self runGitWithArgs: {
		'show'.
		'-s'.
		'--format=tformat:%H%n%D'.
		'HEAD' } ] onErrorDo: [ ^ IceGitUnbornBranch inRepository: self ].
	headRef := lines at: 1.
	ref := ((lines at: 2) splitOn: ', ') first.
	^ head := (ref includesSubstring: '->')
			ifTrue: [ self basicNewBranchNamed: (ref splitOn: ' -> ') second ]
			ifFalse: [ self commitFromGitCommit: headRef ]
]

{ #category : #'private - commits' }
GtIceGitRepository >> iceGitCommitFromLines: lines [
	| author datetime message id parents |
	id := lines at: 1.
	author := lines at: 2.
	datetime := DateAndTime fromUnixTime: (lines at: 3) asInteger.
	parents := (lines at: 4) 
			ifEmpty: [ #() ] 
			ifNotEmpty: [ :line | line splitOn: ' ' ].
	message := String streamContents: [ :str | 
			6 to: lines size do: [ :i | 
				str nextPutAll: (lines at: i); cr ] ].
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
	| args |
	args := { 'init' } asOrderedCollection.
	isBareRepository ifTrue: [ args add: '--bare' ].
	self runGitWithArgs: args
]

{ #category : #initialization }
GtIceGitRepository >> initialize [
	super initialize.
	remoteMap := Dictionary new.
	branchMap := Dictionary new.
	revListMap := Dictionary new.
]

{ #category : #initialization }
GtIceGitRepository >> initializeOn: aFileReference [
	location := aFileReference
]

{ #category : #'private - commits' }
GtIceGitRepository >> internalStoreVersion: aMCVersion [
	self writerClass
		forInternalStoreFileOut: aMCVersion 
		on: self
]

{ #category : #testing }
GtIceGitRepository >> isMissing [
	^ self repositoryDirectory isNil 
		or: [ self repositoryDirectory exists not ]
]

{ #category : #'API - branches' }
GtIceGitRepository >> localBranches [
	| branches |
	branches := self runGitWithArgs: {
		'branch'.
		'--format=%(refname:short)' }.
	^ OrderedCollection streamContents: [ :stream | 
		branches do: [ :br | stream nextPut: (self basicNewBranchNamed: br) ] ]
]

{ #category : #accessing }
GtIceGitRepository >> location [
	^ location
]

{ #category : #actions }
GtIceGitRepository >> location: aLocation [
	location := aLocation 
]

{ #category : #accessing }
GtIceGitRepository >> log [
	^ self logClass for: self
]

{ #category : #accessing }
GtIceGitRepository >> logClass [
	^ GtGitTonelLog
]

{ #category : #'API - commits' }
GtIceGitRepository >> lookupCommit: commitId ifAbsent: aBlock [
	^ [ self commitFromGitCommit: commitId ] onErrorDo: [ aBlock value ]
]

{ #category : #'API - branches' }
GtIceGitRepository >> lookupLocalBranch: branchName [
	^ self lookupLocalBranch: branchName ifAbsent: [ nil ]
]

{ #category : #'API - branches' }
GtIceGitRepository >> lookupLocalBranch: branchName ifAbsent: aBlock [
	^ branchMap
		at: branchName
		ifAbsentPut: [ | lines |
			lines := self runGitWithArgs: {
				'branch'.
				branchName.
				'--list'.
				'--format=%(objectname)' }.
			lines isEmpty ifTrue: [ aBlock value ] ifFalse: [ lines first ] ]
]

{ #category : #'API - branches' }
GtIceGitRepository >> lookupRemoteBranch: branchName [
	^self lookupRemoteBranch: branchName ifAbsent: [nil]
]

{ #category : #'API - branches' }
GtIceGitRepository >> lookupRemoteBranch: branchName ifAbsent: aBlock [
	^ branchMap
		at: branchName
		ifAbsentPut: [ | lines |
			lines := self runGitWithArgs: {
				'branch'.
				branchName.
				'--remotes'.
				'--list'.
				'--format=%(objectname)' }.
			lines isEmpty ifTrue: [ aBlock value ] ifFalse: [ lines first ] ]
]

{ #category : #actions }
GtIceGitRepository >> makeSafe [
]

{ #category : #accessing }
GtIceGitRepository >> mcVersionFor: iceVersion [
	[ | commit |
	commit := iceVersion commit cliGitCommit.
	^ (iceVersion commit readerClass on: commit iceVersion: iceVersion) version ]
		on: Error
		do: [ IceVersionDoesNotExist new
				version: iceVersion;
				signal ]
]

{ #category : #ancestry }
GtIceGitRepository >> mergeBaseBetween: id1 and: id2 [
	| lines |
	lines := self runGitWithArgs: {
		'merge-base'.
		id1.
		id2 }.
	^ lines first
]

{ #category : #'API - accessing' }
GtIceGitRepository >> newCommitWalk [
	^ GtIceCommitWalk forRepository: self
]

{ #category : #'private - changes' }
GtIceGitRepository >> newIndex [
	^ GtIceGitIndex on: self
]

{ #category : #'API - commits' }
GtIceGitRepository >> newNoCommit [
	^ IceNoCommit repository: self
]

{ #category : #'API - remotes' }
GtIceGitRepository >> origin [
	^ self
			remoteNamed: 'origin'
			ifAbsent: [ IceUndefinedRemote new
					name: 'origin';
					yourself ]
]

{ #category : #'API - remotes' }
GtIceGitRepository >> originUrl [
	^ self origin url
]

{ #category : #'private - tags' }
GtIceGitRepository >> peelTag: anIceTag [
	| id lines |
	lines := self runGitWithArgs: {
		'show'.
		'-s'.
		'--format=tformat:%H'.
		anIceTag name }.
	id := lines first.
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

{ #category : #'API - branches' }
GtIceGitRepository >> pullBranch: aString from: aRemote [
	self runGitWithArgs: {
		'pull'.
		aRemote name.
		aString }.
	self clearCaches
]

{ #category : #'API - branches' }
GtIceGitRepository >> pushBranch: aString to: aRemoteName [
	self runGitWithArgs: {
		'push' .
	    aRemoteName . 
	    aString }
]

{ #category : #'API - remotes' }
GtIceGitRepository >> remoteNamed: aName ifAbsent: aBlockClosure [
	^ remoteMap
		at: aName
		ifAbsentPut: [ | gitRemote lines |
			lines := [ self runGitWithArgs: {
				'remote'.
				'get-url'.
				aName } ] onErrorDo: [ ^ aBlockClosure value ].
			gitRemote := lines first trimBoth.
			(IceGitRemote name: aName url: gitRemote)
				localRepository: self;
				yourself ]
]

{ #category : #'API - branches' }
GtIceGitRepository >> remoteTrackedBranches [
	| branches lines |
	lines := self runGitWithArgs: {
		'branch'.
		'--remote'.
		'--format=%(refname)' }.
	branches := lines collect: #trimBoth.
	^ branches collect: [ :each | self basicNewRemoteBranchNamed: each ]
]

{ #category : #'API - remotes' }
GtIceGitRepository >> remotes [
	| lines |
	lines := self runGitWithArgs: { 'remote' }.
	^ lines
		collect: [ :each | 
			| l |
			l := self runGitWithArgs: {
				'remote'.
				'get-url'.
				each }.
			(IceGitRemote name: each url: l first)
				localRepository: self;
				yourself ]
]

{ #category : #'API - accessing' }
GtIceGitRepository >> repositoryDirectory [
	^ self location
]

{ #category : #'API - commits' }
GtIceGitRepository >> revListForBranch: aBranch [
	^ self revListForCommit: aBranch commit id
]

{ #category : #'API - commits' }
GtIceGitRepository >> revListForCommit: aCommit [
	^ revListMap
		at: aCommit
		ifAbsentPut: [ | lines |
			lines := self runGitWithArgs: {
				'rev-list'.
				aCommit }.
			lines collect: #trimBoth ]
]

{ #category : #'API - commits' }
GtIceGitRepository >> revListForCommit: aCommit andPath: aPath [
	| lines |
	lines := self runGitWithArgs: {
		'rev-list'.
		aCommit.
		'--'.
		aPath }.
	^ lines collect: #trimBoth
]

{ #category : #private }
GtIceGitRepository >> runGitWithArgs: args [
	"Run CLI git with the passed arguments and return the lines from standard output.
	Wait for the git command to complete. Signal an error when not successful."

	| processBuilder lines output operation |
	operation := thisContext sender method selector.
	(GtGitCliSignal args: args) 
		operation: operation; 
		markAsStartSignal; 
		emit.
	processBuilder := self git args: args.
	output := self waitForProcessAsync: processBuilder.
	output status isSuccess 
		ifFalse: [
			lines := output stderr lines.
			(GtGitCliSignal args: args output: lines)
				operation: operation;
				markAsEndSignal;
				emit.
			^ GtGitCliError new
				args: args;
				stderr: lines;
				exitCode: output status code;
				signal ].
	lines := output stdout lines.
	(GtGitCliSignal args: args output: lines)
		operation: operation;
		markAsEndSignal;
		emit.
	^ lines
]

{ #category : #'API - accessing' }
GtIceGitRepository >> setHead: aGtIceGitLocalBranch [
	self runGitWithArgs: {
		'update-ref'.
		'HEAD'.
		aGtIceGitLocalBranch commit id }
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
	| lines |
	lines := self runGitWithArgs: { 'tag' }.
	^ lines collect: [ :each | IceTag named: each inRepository: self ]
]

{ #category : #'API - tags' }
GtIceGitRepository >> tagsFor: anId [
	| lines |
	lines := self runGitWithArgs: {
		'tag'.
		'--points-at'.
		anId }.
	^ lines collect: [ :each | IceTag named: each inRepository: self ]
]

{ #category : #private }
GtIceGitRepository >> waitForProcess: processBuilder [
	"Run the native process described in processBuilder and wait for it to complete and produce output.
	The output, an instance of GtNativeExternalProcessOutput, can be queried for its status and stdout.
	This wait will block the VM."
	
	^ processBuilder output
]

{ #category : #private }
GtIceGitRepository >> waitForProcessAsync: processBuilder [
	"Run the native process described in processBuilder and wait for it to complete and produce output.
	The output, an instance of GtNativeExternalProcessOutput, can be queried for its status, stdout and stderr.
	This wait will block the current process but not the VM"

	| nativeProcess |
	processBuilder 
		pipeStdout; 
		pipeStderr.
	nativeProcess := processBuilder spawn.
	^ nativeProcess waitAsyncWithOutput
]

{ #category : #'API - commit' }
GtIceGitRepository >> writeCommit: indexTreeId message: message parents: parentCommits updateReference: ref author: author committer: committer [
	| lines commitId parentArgs |
	self clearCaches.
	parentArgs := (parentCommits
			collect: [ :each | 
				{ '-p'. each id } ]) flatten.
	lines := self runGitWithArgs: 
		{
		'commit-tree'.
		indexTreeId 
		} 
		, 
		parentArgs
		, 
		{
		'-m'.
		message 
		}.
	commitId := lines first trimBoth.
	self runGitWithArgs: {
		'update-ref'.
		ref.
		commitId }.
	self runGitWithArgs: {
		'update-ref'.
		'HEAD'.
		commitId }.
	^ commitId
]

{ #category : #'API - commit' }
GtIceGitRepository >> writeTreeAndReturnOid [
	| lines |
	lines := self runGitWithArgs: { 'write-tree' }.
	^ lines first trimBoth
]

{ #category : #'private - commits' }
GtIceGitRepository >> writerClass [
	^ self project writerClass
]
