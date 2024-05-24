"
Implements the same API as IceLibgitRepository only using the git cli command. Requires a git executable in the path.
"
Class {
	#name : #IceGitCliRepository,
	#superclass : #IceRepository,
	#instVars : [
		'location',
		'head',
		'remoteMap',
		'revListMap',
		'commitMap'
	],
	#category : #'GToolkit4Git-Libgit-CLI'
}

{ #category : #'instance creation' }
IceGitCliRepository class >> fromLibGitRepository: aRepo [
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
IceGitCliRepository class >> gtViewGitCallsIn: composite [
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
IceGitCliRepository class >> on: aFileReference [
	^ self basicNew
		initialize;
		initializeOn: aFileReference
]

{ #category : #accessing }
IceGitCliRepository >> addFilesToIndex: aCollection [
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
IceGitCliRepository >> allBranches [
	^ self localBranches , self remoteTrackedBranches
]

{ #category : #'API - accessing' }
IceGitCliRepository >> basicCodeDirectory [
	^ self subdirectory isEmptyOrNil
		ifTrue: [ self repositoryDirectory ]
		ifFalse: [ self repositoryDirectory / self subdirectory ]
]

{ #category : #'API - branches' }
IceGitCliRepository >> basicNewBranchNamed: aString [ 

	^ IceGitCliLocalBranch named: aString inRepository: self
]

{ #category : #'API - branches' }
IceGitCliRepository >> basicNewRemoteBranchNamed: aString [ 

	^ IceGitCliRemoteBranch named: aString inRepository: self
]

{ #category : #'API - branches' }
IceGitCliRepository >> branchNamed: aString ifPresent: presentBlock ifAbsent: absentBlock [
	| found |
	found := self lookupLocalBranch: aString ifAbsent: [ nil ].
	^ found
		ifNil: absentBlock
		ifNotNil: [ presentBlock value: (self basicNewBranchNamed: aString) ]
]

{ #category : #'private - changes' }
IceGitCliRepository >> changedFilesBetween: aCommitish and: otherCommitish [
	"Answer a list of files that changed between two commits"

	^ self runGitWithArgs: {
		'diff'.
		'--name-only'.
		aCommitish id.
		otherCommitish id }
]

{ #category : #'API - registry' }
IceGitCliRepository >> checkForRegistryConflicts [
	
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
IceGitCliRepository >> clearCaches [
	head := nil.
]

{ #category : #actions }
IceGitCliRepository >> clone: aString [
	self runGitWithArgs: {
		'clone'.
		aString . 
		'.' }
]

{ #category : #'API - accessing' }
IceGitCliRepository >> codeDirectory [
	"Code repository might have been deleted or image might have been moved."
	self repositoryDirectory exists
		ifTrue: [ ^ self basicCodeDirectory ]
		ifFalse: [ IceLocalRepositoryMissing signalFor: self ]
]

{ #category : #'private - commits' }
IceGitCliRepository >> commitFromGitCommit: commitIdString [
	| lines |
	^ commitMap
		at: commitIdString
		ifAbsentPut: [ lines := self
					runGitWithArgs: {'show'.
							'-s'.
							'--format=tformat:%H%n%an%n%at%n%P%n%n%B'.
							commitIdString}.
			self iceGitCommitFromLines: lines ]
]

{ #category : #'private - commits' }
IceGitCliRepository >> commitsFromIds: idCollection [
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

{ #category : #'API - accessing' }
IceGitCliRepository >> config [
	"Return a dictionary of the config values applicable to me"
	| lines values |
	lines := self runGitWithArgs: #('config' '--list').
	values := lines collect: [ :line | $= split: line ].
	values sort: #first ascending.
	^ values 
		collect: [ :each | each first -> each second ] 
		as: OrderedDictionary
]

{ #category : #accessing }
IceGitCliRepository >> configureUpstreamIfNecessary [
	| aRemote gitRemote |
	self branch isUnbornBranch ifTrue: [ ^ self ].
	self branch hasUpstream ifTrue: [ ^ self ].
	#Todo halt.
	
	aRemote := self remoteNamed: 'origin'.
	gitRemote := (LGitRemote
		              of: self repositoryHandle
		              named: aRemote name) lookup.
	self branch
		pushBranchToRemote: aRemote
		gitRemote: gitRemote
		progress: IcePushTransferProgress new.
	self branch setUpstreamIfMissing: aRemote
]

{ #category : #accessing }
IceGitCliRepository >> directoryNameForPackage: package [

	^ (self writerClass 
		directoryNameFor: package)
		asString
]

{ #category : #accessing }
IceGitCliRepository >> directoryPathStringForPackage: aMCPackage [ 

	^ self subdirectory isEmptyOrNil 
		ifTrue: [ self directoryNameForPackage: aMCPackage ]
		ifFalse: [ self subdirectory, '/',  (self directoryNameForPackage: aMCPackage) ]
]

{ #category : #'API - remotes' }
IceGitCliRepository >> fetch [
	"Fetch all commits and branches from all remotes"

	location isNil ifTrue: [ ^ self ].

	self
		runGitWithArgs: {'fetch'.
				'--all'}
]

{ #category : #accessing }
IceGitCliRepository >> fetchBranch: aBranch fromRemote: aRemote [
	self runGitWithArgs: {'fetch'.
		aRemote name.
		aBranch name }
]

{ #category : #'API - accessing' }
IceGitCliRepository >> getDeltasForFullDiff [
	#TODO.
	^ #()
]

{ #category : #'API - accessing' }
IceGitCliRepository >> getStatusByFile [
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
			status := each trimLeft first.
			path := each copyFrom: 4 to: each size.
			res at: path put: (LGitStatusEnum basicNew value: (flagMap at: status)) ].
	^ res
]

{ #category : #actions }
IceGitCliRepository >> git [
	^ GtExternalProcessBuilder new
		command: 'git';
		workingDirectory: location
]

{ #category : #'gt extensions' }
IceGitCliRepository >> gtConfigFor: composite [
	<gtView>
	^ composite forward
		title: 'Config';
		priority: 40;
		object: [ self config ];
		view: #gtItemsFor:
]

{ #category : #'gt extensions' }
IceGitCliRepository >> gtRepositoryDirectoryFor: aView [
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
IceGitCliRepository >> gtStatusFor: aView [
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
IceGitCliRepository >> handleLibgitError: aBlock [
	"Just evaluate the block since we aren't libgit"
	aBlock value
]

{ #category : #'API - accessing' }
IceGitCliRepository >> head [
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
IceGitCliRepository >> iceGitCommitFromLines: lines [
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
	^ IceGitCliCommit new
		id: id;
		author: author;
		datetime: datetime;
		ancestorIds: parents;
		comment: message;
		repository: self;
		yourself
]

{ #category : #actions }
IceGitCliRepository >> initBare: isBareRepository [
	| args |
	args := { 'init' } asOrderedCollection.
	isBareRepository ifTrue: [ args add: '--bare' ].
	self runGitWithArgs: args
]

{ #category : #initialization }
IceGitCliRepository >> initialize [
	super initialize.
	remoteMap := Dictionary new.
	revListMap := Dictionary new.
	commitMap := Dictionary new
]

{ #category : #initialization }
IceGitCliRepository >> initializeOn: aFileReference [
	location := aFileReference
]

{ #category : #'private - commits' }
IceGitCliRepository >> internalStoreVersion: aMCVersion [
	self writerClass
		forInternalStoreFileOut: aMCVersion 
		on: self
]

{ #category : #testing }
IceGitCliRepository >> isMissing [
	^ self repositoryDirectory isNil 
		or: [ self repositoryDirectory exists not ]
]

{ #category : #'API - branches' }
IceGitCliRepository >> localBranches [
	| branches |
	branches := self runGitWithArgs: {
		'branch'.
		'--format=%(refname:short)' }.
	^ OrderedCollection streamContents: [ :stream | 
		branches do: [ :br | stream nextPut: (self basicNewBranchNamed: br) ] ]
]

{ #category : #accessing }
IceGitCliRepository >> location [
	^ location
]

{ #category : #actions }
IceGitCliRepository >> location: aLocation [
	location := aLocation 
]

{ #category : #accessing }
IceGitCliRepository >> log [
	^ self logClass for: self
]

{ #category : #accessing }
IceGitCliRepository >> logClass [
	^ GitCliTonelLog
]

{ #category : #'API - commits' }
IceGitCliRepository >> lookupCommit: commitId ifAbsent: aBlock [
	^ [ self commitFromGitCommit: commitId ] onErrorDo: [ aBlock value ]
]

{ #category : #'API - branches' }
IceGitCliRepository >> lookupLocalBranch: branchName [
	^ self lookupLocalBranch: branchName ifAbsent: [ nil ]
]

{ #category : #'API - branches' }
IceGitCliRepository >> lookupLocalBranch: branchName ifAbsent: aBlock [
	| lines |
	lines := self
			runGitWithArgs: {'branch'.
					branchName.
					'--list'.
					'--format=%(objectname)'}.
	^lines isEmpty ifTrue: [ aBlock value ] ifFalse: [ lines first ]
]

{ #category : #'API - branches' }
IceGitCliRepository >> lookupRemoteBranch: branchName [
	^self lookupRemoteBranch: branchName ifAbsent: [nil]
]

{ #category : #'API - branches' }
IceGitCliRepository >> lookupRemoteBranch: branchName ifAbsent: aBlock [
	| lines |
	lines := self
			runGitWithArgs: {'branch'.
					branchName.
					'--remotes'.
					'--list'.
					'--format=%(objectname)'}.
	^ lines isEmpty ifTrue: [ aBlock value ] ifFalse: [ lines first ]
]

{ #category : #actions }
IceGitCliRepository >> makeSafe [
]

{ #category : #accessing }
IceGitCliRepository >> mcVersionFor: iceVersion [
	[ | commit |
	commit := iceVersion commit cliGitCommit.
	^ (iceVersion commit readerClass on: commit iceVersion: iceVersion) version ]
		on: Error
		do: [ IceVersionDoesNotExist new
				version: iceVersion;
				signal ]
]

{ #category : #ancestry }
IceGitCliRepository >> mergeBaseBetween: id1 and: id2 [
	| lines |
	lines := self runGitWithArgs: {
		'merge-base'.
		id1.
		id2 }.
	^ lines first
]

{ #category : #'API - accessing' }
IceGitCliRepository >> newCommitWalk [
	^ IceGitCliCommitWalk forRepository: self
]

{ #category : #'private - changes' }
IceGitCliRepository >> newIndex [
	^ IceGitCliIndex on: self
]

{ #category : #'API - commits' }
IceGitCliRepository >> newNoCommit [
	^ IceNoCommit repository: self
]

{ #category : #'API - remotes' }
IceGitCliRepository >> origin [
	^ self
			remoteNamed: 'origin'
			ifAbsent: [ IceUndefinedRemote new
					name: 'origin';
					yourself ]
]

{ #category : #'API - remotes' }
IceGitCliRepository >> originUrl [
	^ self origin url
]

{ #category : #'private - tags' }
IceGitCliRepository >> peelTag: anIceTag [
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
IceGitCliRepository >> project [
	^ self workingCopy project
]

{ #category : #accessing }
IceGitCliRepository >> properties [
	^ self workingCopy repositoryProperties
]

{ #category : #'API - branches' }
IceGitCliRepository >> pullBranch: aString from: aRemote [
	self runGitWithArgs: {
		'pull'.
		aRemote name.
		aString }.
	self clearCaches
]

{ #category : #'API - branches' }
IceGitCliRepository >> pushBranch: aString to: aRemoteName [
	self runGitWithArgs: {
		'push' .
	    aRemoteName . 
	    aString }
]

{ #category : #'API - remotes' }
IceGitCliRepository >> remoteNamed: aName ifAbsent: aBlockClosure [
	self remotes.	"Compute cache if empty"
	^ remoteMap at: aName ifAbsent: aBlockClosure
]

{ #category : #'API - branches' }
IceGitCliRepository >> remoteTrackedBranches [
	| branches lines |
	lines := self runGitWithArgs: {
		'branch'.
		'--remote'.
		'--format=%(refname)' }.
	branches := lines collect: #trimBoth.
	^ branches collect: [ :each | self basicNewRemoteBranchNamed: each ]
]

{ #category : #'API - remotes' }
IceGitCliRepository >> remotes [
	| lines |
	remoteMap isEmpty
		ifTrue: [ lines := self runGitWithArgs: {'remote'}.
			lines
				do: [ :each | 
					| l |
					l := self
							runGitWithArgs: {'remote'.
									'get-url'.
									each}.
					remoteMap
						at: each
						put: ((IceGitRemote name: each url: l first)
								localRepository: self;
								yourself) ] ].
	^ remoteMap value
]

{ #category : #'API - accessing' }
IceGitCliRepository >> repositoryDirectory [
	^ self location
]

{ #category : #accessing }
IceGitCliRepository >> repositoryHandle [
	^self
]

{ #category : #'API - commits' }
IceGitCliRepository >> revListForBranch: aBranch [
	^ self revListForCommit: aBranch commit id
]

{ #category : #'API - commits' }
IceGitCliRepository >> revListForCommit: aCommit [
	^ revListMap
		at: aCommit
		ifAbsentPut: [ | lines |
			lines := self runGitWithArgs: {
				'rev-list'.
				aCommit }.
			lines collect: #trimBoth ]
]

{ #category : #'API - commits' }
IceGitCliRepository >> revListForCommit: aCommit andPath: aPath [
	| lines |
	lines := self runGitWithArgs: {
		'rev-list'.
		aCommit.
		'--'.
		aPath }.
	^ lines collect: #trimBoth
]

{ #category : #private }
IceGitCliRepository >> runGitWithArgs: args [
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
IceGitCliRepository >> setHead: aGtIceGitLocalBranch [
	self runGitWithArgs: {
		'update-ref'.
		'HEAD'.
		aGtIceGitLocalBranch commit id }
]

{ #category : #'API - accessing' }
IceGitCliRepository >> subdirectory [
	^ self project sourceDirectory
]

{ #category : #'API - accessing' }
IceGitCliRepository >> subdirectoryPath [
	
	"API compatible both with Pharo6 and Pharo7.
	This could be replaced by the Pharo7 API
	
	RelativePath with: self subdirectory
	"
	^ RelativePath withAll: (RelativePath canonicalizeElements: ($/ split: self subdirectory))
]

{ #category : #accessing }
IceGitCliRepository >> subdirectoryReference [
	^ self location resolve: self subdirectoryPath
]

{ #category : #'API - tags' }
IceGitCliRepository >> tags [
	| lines |
	lines := self runGitWithArgs: { 'tag' }.
	^ lines collect: [ :each | IceTag named: each inRepository: self ]
]

{ #category : #'API - tags' }
IceGitCliRepository >> tagsFor: anId [
	| lines |
	lines := self runGitWithArgs: {
		'tag'.
		'--points-at'.
		anId }.
	^ lines collect: [ :each | IceTag named: each inRepository: self ]
]

{ #category : #private }
IceGitCliRepository >> waitForProcess: processBuilder [
	"Run the native process described in processBuilder and wait for it to complete and produce output.
	The output, an instance of GtNativeExternalProcessOutput, can be queried for its status and stdout.
	This wait will block the VM."
	
	^ processBuilder output
]

{ #category : #private }
IceGitCliRepository >> waitForProcessAsync: processBuilder [
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
IceGitCliRepository >> writeCommit: indexTreeId message: message parents: parentCommits updateReference: ref author: author committer: committer [
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
IceGitCliRepository >> writeTreeAndReturnOid [
	| lines |
	lines := self runGitWithArgs: { 'write-tree' }.
	^ lines first trimBoth
]

{ #category : #'private - commits' }
IceGitCliRepository >> writerClass [
	^ self project writerClass
]
