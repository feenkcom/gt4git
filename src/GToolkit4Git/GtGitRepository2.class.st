Class {
	#name : #GtGitRepository2,
	#superclass : #Object,
	#instVars : [
		'repository',
		'status',
		'headDescription',
		'isModified',
		'currentCommitMessage',
		'lepiterWorkingCopy'
	],
	#classVars : [
		'RecentCommitMessage'
	],
	#category : #'GToolkit4Git-Inspector Integration'
}

{ #category : #'instance creation' }
GtGitRepository2 class >> fromIcebergRepository: anIceRepository [
	^ self new repository: anIceRepository
]

{ #category : #accessing }
GtGitRepository2 >> addPackage: aSymbol [
	self workingCopy addPackageNamed: aSymbol
]

{ #category : #accessing }
GtGitRepository2 >> currentCommitMessage [
	<return: #BlText>
	^ currentCommitMessage ifNil: [
		currentCommitMessage := self recentCommitMessage asRopedText ]
]

{ #category : #actions }
GtGitRepository2 >> executeCommit: aCommitMessage [
	|diff|
	diff := self workingCopyDiff.
	self workingCopy 
		commitChanges: diff
		withMessage: aCommitMessage
		force: false.
	Iceberg announcer announce: (IceRepositoryModified for: self repository).
]

{ #category : #'gt-extensions' }
GtGitRepository2 >> gtActionFetchFor: anAction [
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

{ #category : #'gt-extensions' }
GtGitRepository2 >> gtActionPullFor: anAction [

	<gtAction>
	self isMissing ifTrue: [ ^ anAction ].
	(IceTipRepositoryModel on: self repository) isDetached ifTrue: [ 
		^ anAction ].
	^ anAction button
		  label: 'Pull';
		  priority: 3;
		  action: [ :aButton | 
			  [ self repository pull ]
				  on: IceMergeResolutionRequest
				  do: [ :r | aButton phlow spawnObject: r merge ].
			  Iceberg announcer announce:
					  (IceRepositoryModified for: self repository).
			  aButton phlow fireUpdateWish ]
]

{ #category : #'gt-extensions' }
GtGitRepository2 >> gtActionPushFor: anAction [
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

{ #category : #'gt-extensions' }
GtGitRepository2 >> gtActionRefreshFor: anAction [
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

{ #category : #'gt-extensions' }
GtGitRepository2 >> gtActionRepairFor: anAction [
	<gtAction>
	self isMissing ifTrue: [ ^ anAction ].
	(GtGitRepairAction subclasses 
		select: [:sc | sc iceTipClass isAvailableFor: repository]) size = 0 ifTrue: [ ^ anAction ].
	^ anAction dropdown
		label: 'Repair';
		content: [:aDropdown | 
			GtGitRepositoryRepairStencil new repository:repository; dropdown: aDropdown ].
]

{ #category : #'gt-extensions' }
GtGitRepository2 >> gtChangesFor: aView [
	<gtView>
	| changes |
	self lepiterWorkingCopy ifNil: [ ^ aView empty ].
	changes := self workingCopyDiff treeToShow.
	(changes isNil or: [ changes isEmpty ]) ifTrue: [ ^ aView empty ].
	^ aView tree
		  title: 'Changes';
		  items: [ changes children ];
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
				  aptitude: (BrGlamorousWithContextMenuAptitude content: [ 
							   BrGlamorousSimpleContextMenuContent new
								   items: { ('Revert changes' -> [ :e | 
										    self workingCopy diffToReferenceCommit revertChanges:
												    anIceNode ]) };
								   yourself ]);
				  addChild:
					  (anIceNode value icon asElement constraintsDo: [ :c | 
						   c linear horizontal alignCenter ]);
				  addChild: (BrLabel new
						   aptitude: BrGlamorousLabelAptitude;
						   text: anIceNode value name asString asRopedText;
						   padding: (BlInsets
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
				            aptitude: BrGlamorousRegularEditorAptitude;
				            text: self currentCommitMessage.
			  editor selecter
				  all;
				  select.

			  button := BrButton new.
			  button
				  aptitude: BrGlamorousButtonWithIconAptitude;
				  icon: BrGlamorousVectorIcons accept;
				  label: 'Commit';
				  disabled: editor text isEmpty;
				  action: [ 
					  self recentCommitMessage: editor text asString.
					  self executeCommit: editor editor text asString.
					  button disable.
					  self resetCurrentCommitMessage.
					  aDropdown enqueueTask: (BlTaskAction new action: [ 
									   aDropdown dispatchEvent:
											   (BrDropdownHideWish new anchor: aDropdown).
									   aDropdown phlow fireUpdateWish ]) ].

			  editor editor
				  when: BrTextEditorModifiedEvent
				  do: [ :anEvent | button disabled: anEvent text isEmpty ].

			  BrVerticalPane new
				  hExact: 400;
				  vFitContentLimited;
				  padding: (BlInsets all: 10);
				  addChildren: { 
						  editor.
						  button } ]
]

{ #category : #'gt-extensions' }
GtGitRepository2 >> gtCommitsFor: aView [
	<gtView>
	self repository repositoryDirectory ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Commits';
		object: [ self repository branch ];
		view: #gtCommitsFor:
]

{ #category : #printing }
GtGitRepository2 >> gtDisplayOn: aStream [

	self repository repositoryDirectory ifNil: [ 
		^ aStream
			  nextPutAll: self name;
			  nextPutAll: ', ';
			  nextPutAll: self status ].
	aStream nextPutAll: self repository repositoryDirectory pathString
]

{ #category : #'gt-extensions' }
GtGitRepository2 >> gtPackagesFor: aView [
	<gtView>
	^ self repository workingCopy 
		ifNil: [ aView empty ]
		ifNotNil: [ 
			self repository workingCopy gtPackagesFor: aView ]
]

{ #category : #'gt-extensions' }
GtGitRepository2 >> gtRepositoryDirectoryFor: aView [
	<gtView>
	^ (self repository gtRepositoryDirectoryFor: aView) priority: 40
]

{ #category : #'gt-extensions' }
GtGitRepository2 >> gtViewIncomingCommitsFor: aView [

	<gtView>
	| incomingCommits |
	self repository repositoryDirectory ifNil: [ ^ aView empty ].
	incomingCommits := GtRlIceCommitsGroup forCommits:
		                   self repository incomingCommits.
	incomingCommits commits ifEmpty: [ ^ aView empty ].

	^ (incomingCommits gtViewCommitsListFor: aView)
		  title: 'Incoming commits' translated;
		  updateWhen: IceCommited
		  in: Iceberg announcer;
		  updateWhen: IceRepositoryModified
		  in: Iceberg announcer;
		  priority: 10;
		  actionButtonLabel: 'Merge' action: [ :aButton | 
			  | remoteBranch |
			  remoteBranch := self repository branch upstream remote
				                  remoteBranchNamed: self repository branch name
				                  ifAbsent: [ self repository branch ].

			  [ self repository workingCopy mergeCommit: remoteBranch commit ]
				  on: IceMergeResolutionRequest
				  do: [ :r | aButton phlow spawnObject: r merge ].
			  Iceberg announcer announce:
					  (IceRepositoryModified for: self repository).
			  aButton phlow fireUpdateWish ]
]

{ #category : #'gt-extensions' }
GtGitRepository2 >> gtViewOutgoingCommitsFor: aView [
	<gtView>
	| outgoingCommits |
	self repository repositoryDirectory ifNil: [  ^ aView empty ].
	outgoingCommits := GtRlIceCommitsGroup forCommits: self repository outgoingCommits.
	^ outgoingCommits commits
		ifEmpty: [ aView empty ]
		ifNotEmpty: [ 
			(outgoingCommits gtViewCommitsListFor: aView)
				title: 'Outgoing commits';
				priority: 12 ]
]

{ #category : #accessing }
GtGitRepository2 >> head [
 ^ repository head
]

{ #category : #accessing }
GtGitRepository2 >> headDescription [
	^ headDescription ifNil: [ headDescription := self repository headDescription ]
]

{ #category : #accessing }
GtGitRepository2 >> incomingCommits [
	^ repository incomingCommits
]

{ #category : #testing }
GtGitRepository2 >> isMissing [
^ self repository repositoryDirectory isNil 
		or: [ self repository repositoryDirectory exists not ]
]

{ #category : #testing }
GtGitRepository2 >> isModified [
	^ self repository isModified or: [ self repository isDirty ]
]

{ #category : #accessing }
GtGitRepository2 >> lepiterWorkingCopy [
	^ lepiterWorkingCopy
]

{ #category : #actions }
GtGitRepository2 >> load [
	self status.
	self headDescription.
	self isModified
]

{ #category : #accessing }
GtGitRepository2 >> name [
	^ self repository name
]

{ #category : #accessing }
GtGitRepository2 >> outgoingCommits [
	^ repository outgoingCommits
]

{ #category : #actions }
GtGitRepository2 >> pull [
]

{ #category : #accessing }
GtGitRepository2 >> recentCommitMessage [
	^ RecentCommitMessage ifNil: [ '' ]
]

{ #category : #accessing }
GtGitRepository2 >> recentCommitMessage: aString [ 
	RecentCommitMessage := aString asString
]

{ #category : #accessing }
GtGitRepository2 >> repository [
	<return: #IceRepository>

	^ repository
]

{ #category : #accessing }
GtGitRepository2 >> repository: anIceRepository [
	repository := anIceRepository.
	lepiterWorkingCopy := GtLepiterWorkingCopy new 
		repository: anIceRepository; 
		updateDatabases.
]

{ #category : #actions }
GtGitRepository2 >> reset [
	status := nil.
	headDescription := nil.
	isModified := nil
]

{ #category : #actions }
GtGitRepository2 >> resetCurrentCommitMessage [
	currentCommitMessage := nil
]

{ #category : #accessing }
GtGitRepository2 >> status [
	^ status ifNil: [ status := (IceTipRepositoryModel on: self repository) status asString ]
]

{ #category : #accessing }
GtGitRepository2 >> workingCopy [
	^ self repository workingCopy
]

{ #category : #accessing }
GtGitRepository2 >> workingCopyDiff [
	
	^ self lepiterWorkingCopy diffToReferenceCommit
]
