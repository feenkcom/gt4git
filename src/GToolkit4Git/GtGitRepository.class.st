Class {
	#name : #GtGitRepository,
	#superclass : #Object,
	#instVars : [
		'repository',
		'status',
		'headDescription',
		'isModified'
	],
	#category : #GToolkit4Git
}

{ #category : #'instance creation' }
GtGitRepository class >> fromIcebergRepository: anIceRepository [
	^ self new repository: anIceRepository
]

{ #category : #accessing }
GtGitRepository >> executeCommit: aCommitMessage [
	|diff|
	diff := self repository workingCopyDiff.
	self workingCopy 
		commitChanges: diff
		withMessage: aCommitMessage
		force: false.
	Iceberg announcer announce: (IceRepositoryModified for: self repository).
]

{ #category : #accessing }
GtGitRepository >> gtActionFetchFor: anAction [
	<gtAction>
	self isMissing ifTrue: [ ^ anAction ].
	^ anAction button
		label: 'Fetch';
		action: [ 
			(IceTipRepositoryModel on: self repository) fetch.
				Iceberg announcer announce: (IceRepositoryModified for: self repository) ]
]

{ #category : #accessing }
GtGitRepository >> gtActionPullFor: anAction [
	<gtAction>
	self isMissing ifTrue: [ ^ anAction ].
	(IceTipRepositoryModel on:self repository) isDetached ifTrue: [ ^ anAction ].
	^ anAction button
		label: 'Pull';
		action: [ :aButton | 
			self repository pull.
			Iceberg announcer announce: (IceRepositoryModified for: self repository) ]
]

{ #category : #accessing }
GtGitRepository >> gtActionPushFor: anAction [
	<gtAction>
	self isMissing ifTrue: [ ^ anAction ].
	(IceTipRepositoryModel on:self repository) isDetached ifTrue: [ ^ anAction ].
	^ anAction button
		label: 'Push';
		action: [ :aButton | 
			self repository push.
			Iceberg announcer announce: (IceRepositoryModified for: self repository) ]
]

{ #category : #accessing }
GtGitRepository >> gtActionRefreshFor: anAction [
	<gtAction>
	self isMissing ifTrue: [ ^ anAction ].
	^ anAction button
		label: 'Refresh';
		action: [ 
		
			"Aim to only recalculate the dirty flag for packages that are marked as dirty.
			We skip packages that are not marked as dirty."

			| icebergRepository diff dirtyPackages |
			icebergRepository := self repository.
			icebergRepository isModified ifFalse: [ 
				"If the repository is not marked as modified no action is needed here"
				^ self ]. 

			"We compite the diff but only recalculate the status for dirty packages"
			diff := IceDiff new
				sourceVersion: icebergRepository workingCopy;
				targetVersion: icebergRepository workingCopy referenceCommit;
				buildFull.
		
			dirtyPackages:= icebergRepository loadedPackages 
				select: [ :each | each isDirty ].
			dirtyPackages do: [ :each |
				each beDirty: (diff includesPackageNamed: each name) ].
				Iceberg announcer announce: (IceRepositoryModified for: self repository)]
]

{ #category : #accessing }
GtGitRepository >> gtChangesFor: aView [
	<gtView>
	self workingCopy ifNil: [ ^ aView empty ].
	self workingCopy diffToReferenceCommit treeToShow children
		ifEmpty: [ ^ aView empty ].
	^ aView tree
		title: 'Changes';
		items: [ self workingCopy diffToReferenceCommit treeToShow children ];
		updateWhen: IceRepositoryModified in: Iceberg announcer;
		children: #children;
		expandUpTo: 3;
		stencil: [ :anIceNode | 
			BlElement new
				layout: BlLinearLayout horizontal;
				constraintsDo: [ :c | 
					c horizontal matchParent.
					c vertical fitContent ];
				margin: (BlInsets all: 3);
				constraintsDo: [ :c | c vertical fitContent ];
				look:
					(BrGlamorousWithContextMenuLook
						content: [ BrGlamorousSimpleContextMenuContent new
								items:
									{('Revert changes'
										->
											[ :e | self workingCopy diffToReferenceCommit revertChanges: anIceNode ])};
								yourself ]);
				addChild:
					(anIceNode value icon asElement
						constraintsDo: [ :c | c linear horizontal alignCenter ]);
				addChild:
					(BrLabel new
						look: BrGlamorousLabelLook;
						text: anIceNode key asString asRopedText;
						padding:
							(BlInsets
								top: 0
								left: 6
								bottom: 0
								right: 3);
						constraintsDo: [ :c | c linear horizontal alignCenter ]) ];
		actionDropdownButtonLabel: 'Commit'
			tooltip: 'Commit changes'
			content: [ :aDropdown :aTarget | 
			| editor button |
			editor := BrEditor new look: BrGlamorousRegularEditorLook.
			button := BrButton new
				look: BrGlamorousButtonWithIconLook;
				icon: BrGlamorousVectorIcons accept;
				label: 'Commit'.
			button
				action: [ self executeCommit: editor editor text asString.
					button disable.
					aDropdown
						enqueueTask:
							(BlTaskAction new
								action:
									[ aDropdown dispatchEvent: (BrDropdownHideWish new anchor: aDropdown) ]) ].
			button disable.
			editor editor
				when: BrTextEditorModifiedEvent
				do: [ :anEvent | 
					anEvent text asString isEmpty
						ifTrue: [ button disable ];
						ifFalse: [ self workingCopy diffToReferenceCommit treeToShow children
									ifNotEmpty: [ button enable ] ] ].
			BlElement new
				constraintsDo: [ :c | 
					c horizontal exact: 400.
					c vertical fitContent ];
				layout: BlLinearLayout vertical;
				padding: (BlInsets all: 10);
				addChild: editor;
				addChild: button ]
]

{ #category : #accessing }
GtGitRepository >> gtViewIncomingCommitsFor: aView [
	<gtView>
	| incomingCommits |
	incomingCommits := GtRlIceCommitsGroup forCommits: self repository incomingCommits.
	incomingCommits commits ifEmpty: [ ^ aView ].
	
	^ (incomingCommits gtViewCommitsListFor: aView)
		title: 'Incoming commits' translated;
		priority: 10;
		actionButtonLabel: 'Merge' action: [ 
			| remoteBranch |
			remoteBranch := self repository branch upstream remote 
				remoteBranchNamed: self repository branch name 
				ifAbsent: [ self repository branch ].
			self repository workingCopy mergeCommit: remoteBranch commit.
			Iceberg announcer announce: (IceRepositoryModified for: self repository) ]
]

{ #category : #accessing }
GtGitRepository >> gtViewOutgoingCommitsFor: aView [
	<gtView>
	| outgoingCommits |
	outgoingCommits := GtRlIceCommitsGroup forCommits: self repository outgoingCommits.
	^ outgoingCommits commits
		ifEmpty: [ aView ]
		ifNotEmpty: [ 
			(outgoingCommits gtViewCommitsListFor: aView)
				title: 'Outgoing commits';
				priority: 12 ]
]

{ #category : #accessing }
GtGitRepository >> headDescription [
	^ headDescription ifNil: [ headDescription := self repository headDescription ]
]

{ #category : #accessing }
GtGitRepository >> isMissing [
^ self repository repositoryDirectory isNil 
		or: [ self repository repositoryDirectory exists not ]
]

{ #category : #accessing }
GtGitRepository >> isModified [
	^ isModified ifNil: [ isModified := self repository isModified ]
]

{ #category : #initialization }
GtGitRepository >> load [
	self status.
	self headDescription.
	self isModified
]

{ #category : #accessing }
GtGitRepository >> name [
	^ self repository name
]

{ #category : #accessing }
GtGitRepository >> pull [
]

{ #category : #accessing }
GtGitRepository >> repository [
	<return: #IceRepository>

	^ repository
]

{ #category : #accessing }
GtGitRepository >> repository: anIceRepository [
	repository := anIceRepository
]

{ #category : #initialization }
GtGitRepository >> reset [
	status := nil.
	headDescription := nil.
	isModified := nil
]

{ #category : #accessing }
GtGitRepository >> status [
	^ status ifNil: [ status := (IceTipRepositoryModel on: self repository) status ]
]

{ #category : #accessing }
GtGitRepository >> workingCopy [
	^ self repository workingCopy
]
