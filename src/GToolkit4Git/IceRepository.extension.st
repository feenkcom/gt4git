Extension { #name : #IceRepository }

{ #category : #'*GToolkit4Git' }
IceRepository >> gtLocalBranchesFor: aView [
	<gtView>
	^ aView list  
		title: 'Branches' translated;
		priority: 20;
		items: [ self localBranches ];
		itemFormat: #name
]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtPackagesFor: aView [
	<gtView>
	^ self workingCopy 
		ifNil: [ aView ]
		ifNotNil: [ self workingCopy gtPackagesFor: aView ]
]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtRemoteBranchesFor: aView [
	<gtView>
	^ aView list  
		title: 'Remotes' translated;
		priority: 24;
		items: [ self remoteTrackedBranches ];
		itemFormat: #name
]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtTagsFor: aView [
	<gtView>
	^ aView list 
		title: 'Tags' translated;
		priority: 30;
		items: [ self tags ];
		itemFormat: [ :anIceTag |
			anIceTag name, ' [', (anIceTag commit id first: 7), ']' ]
]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtViewDiffToReferenceCommitFor: aView [
	"<gtView>"
	^ self workingCopy 
		ifNil: [ aView ]
		ifNotNil: [ self workingCopy gtViewDiffToReferenceCommitFor: aView ]
]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtViewIncomingCommitsFor: aView [
	<gtView>
	| incomingCommits |
	incomingCommits := GtRlIceCommitsGroup forCommits: self incomingCommits.
	incomingCommits commits ifEmpty: [ ^ aView ].
	
	^ (incomingCommits gtViewCommitsListFor: aView)
		title: 'Incoming commits' translated;
		priority: 10;
		actionButtonLabel: 'Merge' action: [ 
			| remoteBranch |
			remoteBranch := self branch upstream remote 
				remoteBranchNamed: self branch name 
				ifAbsent: [ self branch ].
			self workingCopy mergeCommit: remoteBranch commit ]
]

{ #category : #'*GToolkit4Git' }
IceRepository >> gtViewOutgoingCommitsFor: aView [
	<gtView>
	| outgoingCommits |
	outgoingCommits := GtRlIceCommitsGroup forCommits: self outgoingCommits.
	^ outgoingCommits commits
		ifEmpty: [ aView ]
		ifNotEmpty: [ 
			(outgoingCommits gtViewCommitsListFor: aView)
				title: 'Outgoing commits';
				priority: 12 ]
]
