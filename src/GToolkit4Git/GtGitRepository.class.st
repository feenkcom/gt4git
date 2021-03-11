Class {
	#name : #GtGitRepository,
	#superclass : #Object,
	#instVars : [
		'repository',
		'status',
		'headDescription',
		'isModified',
		'currentCommitMessage'
	],
	#classVars : [
		'RecentCommitMessage'
	],
	#category : #GToolkit4Git
}

{ #category : #'instance creation' }
GtGitRepository class >> fromIcebergRepository: anIceRepository [
	^ self new repository: anIceRepository
]

{ #category : #accessing }
GtGitRepository >> currentCommitMessage [
	<return: #BlText>
	^ currentCommitMessage ifNil: [
		currentCommitMessage := self recentCommitMessage asRopedText ]
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
		priority: 2;
		action: [ :aButton |
			(IceTipRepositoryModel on: self repository) fetch.
			Iceberg announcer announce: (IceRepositoryModified for: self repository).
			aButton phlow fireUpdateWish ]
]

{ #category : #accessing }
GtGitRepository >> gtActionPullFor: anAction [
	<gtAction>
	self isMissing ifTrue: [ ^ anAction ].
	(IceTipRepositoryModel on:self repository) isDetached ifTrue: [ ^ anAction ].
	^ anAction button
		label: 'Pull';
		priority: 3;
		action: [ :aButton | 
			self repository pull.
			Iceberg announcer announce: (IceRepositoryModified for: self repository).
			aButton phlow fireUpdateWish ]
]

{ #category : #accessing }
GtGitRepository >> gtActionPushFor: anAction [
	<gtAction>
	self isMissing ifTrue: [ ^ anAction ].
	(IceTipRepositoryModel on:self repository) isDetached ifTrue: [ ^ anAction ].
	^ anAction button
		label: 'Push';
		priority: 4;
		action: [ :aButton | 
			self repository push.
			Iceberg announcer announce: (IceRepositoryModified for: self repository).
			
			aButton phlow fireUpdateWish ]
]

{ #category : #accessing }
GtGitRepository >> gtActionRefreshFor: anAction [
	<gtAction>
	self isMissing ifTrue: [ ^ anAction ].
	^ anAction button
		label: 'Refresh';
		priority: 1;
		action: [ :aButton |
		
			"Aim to only recalculate the dirty flag for packages that are marked as dirty.
			We skip packages that are not marked as dirty."

			| icebergRepository diff dirtyPackages |
			icebergRepository := self repository.
			icebergRepository isModified ifTrue: [ 
				"If the repository is not marked as modified no action is needed here"


			"We compite the diff but only recalculate the status for dirty packages"
			diff := IceDiff new
				sourceVersion: icebergRepository workingCopy;
				targetVersion: icebergRepository workingCopy referenceCommit;
				buildFull.
		
			dirtyPackages:= icebergRepository loadedPackages 
				select: [ :each | each isDirty ].
			dirtyPackages do: [ :each |
				each beDirty: (diff includesPackageNamed: each name) ].
				Iceberg announcer announce: (IceRepositoryModified for: self repository)]. 
				
			aButton phlow fireUpdateWish ]. 
]

{ #category : #accessing }
GtGitRepository >> gtActionRepairFor: anAction [
	<gtAction>
	self isMissing ifTrue: [ ^ anAction ].
	(GtGitRepairAction subclasses 
		select: [:sc | sc iceTipClass isAvailableFor: repository]) size = 0 ifTrue: [ ^ anAction ].
	^ anAction dropdown
		label: 'Repair';
		content: [:aDropdown | 
			GtGitRepositoryRepairStencil new repository:repository; dropdown: aDropdown ].
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
		priority: 10;
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
			
			editor := BrEditor new
				hMatchParent;
				vFitContentLimited;
				look: BrGlamorousRegularEditorLook;
				text: self currentCommitMessage.
			editor selecter all; select.
			
			button := BrButton new.
			button
				look: BrGlamorousButtonWithIconLook;
				icon: BrGlamorousVectorIcons accept;
				label: 'Commit';
				disabled: editor text isEmpty;
				action: [ 
					self recentCommitMessage: editor text asString.
					self executeCommit: editor editor text asString.
					button disable.
					self resetCurrentCommitMessage.
					aDropdown enqueueTask: (BlTaskAction new
						action: [ 
							aDropdown dispatchEvent: (BrDropdownHideWish new anchor: aDropdown).
							aDropdown phlow fireUpdateWish ]) ].

			editor editor
				when: BrTextEditorModifiedEvent
				do: [ :anEvent | button disabled: anEvent text isEmpty ].

			BrVerticalPane new
				hExact: 400;
				vFitContentLimited;
				padding: (BlInsets all: 10);
				addChildren: { editor . button } ]
]

{ #category : #accessing }
GtGitRepository >> gtCommitsFor: aView [
	<gtView>
	^ aView forward
		title: 'Commits';
		object: [ self repository branch ];
		view: #gtCommitsFor:
]

{ #category : #accessing }
GtGitRepository >> gtDisplayOn: aStream [
	aStream nextPutAll: self repository repositoryDirectory pathString
]

{ #category : #accessing }
GtGitRepository >> gtPackagesFor: aView [
	<gtView>
	^ self repository workingCopy 
		ifNil: [ aView ]
		ifNotNil: [ self repository workingCopy gtPackagesFor: aView ]
]

{ #category : #accessing }
GtGitRepository >> gtRepositoryDirectoryFor: aView [
	<gtView>
	^ (self repository gtRepositoryDirectoryFor: aView) priority: 40
]

{ #category : #accessing }
GtGitRepository >> gtViewIncomingCommitsFor: aView [
	<gtView>
	| incomingCommits |
	incomingCommits := GtRlIceCommitsGroup forCommits: self repository incomingCommits.
	incomingCommits commits ifEmpty: [ ^ aView empty ].
	
	^ (incomingCommits gtViewCommitsListFor: aView)
		title: 'Incoming commits' translated;
		priority: 10;
		actionButtonLabel: 'Merge' action: [ :aButton |
			| remoteBranch |
			remoteBranch := self repository branch upstream remote 
				remoteBranchNamed: self repository branch name 
				ifAbsent: [ self repository branch ].
			self repository workingCopy mergeCommit: remoteBranch commit.
			Iceberg announcer announce: (IceRepositoryModified for: self repository).
			aButton phlow fireUpdateWish ]
]

{ #category : #accessing }
GtGitRepository >> gtViewOutgoingCommitsFor: aView [
	<gtView>
	| outgoingCommits |
	outgoingCommits := GtRlIceCommitsGroup forCommits: self repository outgoingCommits.
	^ outgoingCommits commits
		ifEmpty: [ aView empty ]
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
GtGitRepository >> recentCommitMessage [
	^ RecentCommitMessage ifNil: [ '' ]
]

{ #category : #accessing }
GtGitRepository >> recentCommitMessage: aString [ 
	RecentCommitMessage := aString asString
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
GtGitRepository >> resetCurrentCommitMessage [
	currentCommitMessage := nil
]

{ #category : #accessing }
GtGitRepository >> status [
	^ status ifNil: [ status := (IceTipRepositoryModel on: self repository) status asString ]
]

{ #category : #accessing }
GtGitRepository >> workingCopy [
	^ self repository workingCopy
]
