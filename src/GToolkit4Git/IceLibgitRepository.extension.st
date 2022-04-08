Extension { #name : #IceLibgitRepository }

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> configureUpstreamIfNecessary [

	| aRemote gitRemote |
	self branch isUnbornBranch ifTrue: [ ^ self ].
	self branch hasUpstream ifTrue: [ ^ self ].
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

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> getDeltasForFullDiff [
	"Return the deltas including untracked files.
	This makes it possible to create a full diff of what changed."

	| out res |
	self handleLibgitError: [ 
		out := LGitDiff of: self.
		res := (self repositoryHandle 
			getDeltasFromHead: self head
			options: (LGitDiffOptions defaults
				prim_flags: (LGitDiffOptionTypeEnum git_diff_include_untracked value 
					bitXor: LGitDiffOptionTypeEnum git_diff_recurse_untracked_dirs value))
			into: out) 
					collect: [ :delta | 
						GtGitDelta from: delta in: self ].
		out free.
		^ res ]
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> getStatusByFile [

	| res |
	res := Dictionary new.

	self repositoryHandle index allFilesStatusDo: [ :path :flags :_ | 
		res at: path put: (LGitStatusEnum fromInteger: flags).
		0 ].

	^ res
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtLocalBranchesFor: aView [
	<gtView>
	self isMissing ifTrue: [ ^ aView empty ].
	^ super gtLocalBranchesFor: aView
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtRawStatusFor: aView [
	<gtView>
	self isMissing ifTrue: [ ^ aView empty ].
	
	^ aView columnedList
		title: 'Raw File Statuses';
		priority: 100;
		items: [ self getStatusByFile associations ];
		column: 'File'
		text: [:each | each key ];
		column: 'Status'
		text: [:each | each value ]
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtRemoteBranchesFor: aView [
	<gtView>
	self isMissing ifTrue: [ ^ aView empty ].
	^ super gtRemoteBranchesFor: aView
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtRepositoryDirectoryFor: aView [
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
						  ifFalse: [ BrGlamorousIcons accept ] ] ];
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

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtStatusFor: aView [
	<gtView>
	
	self isMissing ifTrue: [ ^ aView empty ].
	^ aView columnedTree
		  title: 'File Statuses';
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

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> gtTagsFor: aView [
	<gtView>
	self isMissing ifTrue: [ ^ aView empty ].
	^ super gtTagsFor: aView
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> isDirty [

	^ handle ifNil: [ false ] ifNotNil: [ handle isDirty ]
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> makeSafe [
 self commitCache ensureThreadSafe
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> originUrl [
	^ self origin url
]

{ #category : #'*GToolkit4Git' }
IceLibgitRepository >> setOriginTo: url [
	(LGitRemote of: self repositoryHandle named: 'origin')
		lookup;
		setUrl: url.
]
