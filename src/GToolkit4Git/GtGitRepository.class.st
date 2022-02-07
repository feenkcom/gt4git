Class {
	#name : #GtGitRepository,
	#superclass : #Object,
	#traits : 'TGtAnnouncer',
	#classTraits : 'TGtAnnouncer classTrait',
	#instVars : [
		'repository',
		'announcer',
		'isSubscribed',
		'lepiterWorkingCopy',
		'status',
		'viewModel'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #announcer }
GtGitRepository >> announcer [
	<return: #Announcer>
	^ announcer
]

{ #category : #'api - repository' }
GtGitRepository >> changes [
	^ self isModified
		ifTrue: [ self workingCopy diffToReferenceCommit treeToShow children ]
		ifFalse: [ Array empty ]
]

{ #category : #accessing }
GtGitRepository >> conflictingCommits [

	^ self incomingCommits select: [ :commit | 
		  (IceMerge new
			   repository: self repository;
			   mergeCommit: commit) hasConflicts ]
]

{ #category : #'api - actions' }
GtGitRepository >> executeCommit: aCommitMessage [

	| workingCopyDiff |
	workingCopyDiff := self workingCopyDiff.
	self workingCopy
		commitChanges: workingCopyDiff
		withMessage: aCommitMessage
		force: false.
	Iceberg announcer announce:
		(IceRepositoryModified for: self repository)
]

{ #category : #accessing }
GtGitRepository >> executeCommit: aCommitMessage withChanges: changes [

	| workingCopyDiff |
	workingCopyDiff := self workingCopyDiff.
	self workingCopy
		commitChanges: (workingCopyDiff copyWithOnly: changes)
		withMessage: aCommitMessage
		force: false.
	Iceberg announcer announce:
		(IceRepositoryModified for: self repository)
]

{ #category : #'api - actions' }
GtGitRepository >> fetch [
	self repository fetch.
	Iceberg announcer announce: (IceRepositoryModified for: self repository)
]

{ #category : #accessing }
GtGitRepository >> forget [
	self repository forget
]

{ #category : #accessing }
GtGitRepository >> gtActionFetchFor: anAction [
	<gtAction>
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

{ #category : #accessing }
GtGitRepository >> gtActionPushFor: anAction [
	<gtAction>
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
	(GtGitRepairAction subclasses 
		select: [:sc | sc iceTipClass isAvailableFor: repository]) size = 0 ifTrue: [ ^ anAction ].
	^ anAction dropdown
		label: 'Repair';
		content: [:aDropdown | 
			GtGitRepositoryRepairStencil new repository:repository; dropdown: aDropdown ].
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtChangesFor: aView context: aContext [

	<gtView>
	<gtRepositoryView>
	| aViewModel changes chosen |
	chosen := Set new.

	aViewModel :=self viewModel.

	self lepiterWorkingCopy ifNil: [ ^ aView empty ].
	changes := self workingCopyDiff treeToShow.
	(changes isNil or: [ changes isEmpty ]) ifTrue: [ ^ aView empty ].
	^ aView tree
		  title: 'Changes';
		  items: [ changes children ];
		  children: #children;
		  expandUpTo: 3;
		  priority: 1;
		  stencil: [ :anIceNode | 
			  | element |
			  anIceNode value hasChanges ifTrue: [ chosen add: anIceNode ].
			  element := BlElement new
				             layout: BlLinearLayout horizontal alignCenterLeft;
				             constraintsDo: [ :c | 
					             c horizontal matchParent.
					             c vertical fitContent ];
				             margin: (BlInsets all: 3);
				             constraintsDo: [ :c | c vertical fitContent ];
				             aptitude:
					             (BrGlamorousWithContextMenuAptitude content: [ 
							              BrGlamorousSimpleContextMenuContent new
								              items: { ('Revert changes' -> [ :e | 
										               self workingCopy diffToReferenceCommit 
											               revertChanges: anIceNode ]) };
								              yourself ]).
			  anIceNode value hasChanges ifTrue: [ 
				  element addChild: (BrCheckbox new
						   aptitude: BrGlamorousCheckboxAptitude
							   +
								   (BrGlamorousWithLabelTooltipAptitude new text:
										    'Select for Commit');
						   checked: true;
						   whenCheckedDo: [ chosen add: anIceNode ];
						   margin: (BlInsets right: 8);
						   whenUncheckedDo: [ chosen remove: anIceNode ifAbsent: [  ] ]) ].
			  element
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
				            text: aViewModel commitMessage.
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
					  aViewModel
						  executeCommit: editor editor text asString
						  withChanges: chosen.
					  button disable.
					  aDropdown enqueueTask: (BlTaskAction new action: [ 
									   aDropdown dispatchEvent:
											   (BrDropdownHideWish new anchor: aDropdown) ]).
					  aDropdown phlow fireUpdateWish ].

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

{ #category : #accessing }
GtGitRepository >> gtCommitButtonsFor: item [

	| container merge |
	container := BlElement new height: 24.

	((self incomingCommits contains: [ :aCommit | aCommit = item ]) and: [ 
		 (merge := IceMerge new
			           repository: self repository;
			           mergeCommit: item) hasConflicts ]) ifTrue: [ 
		container addChild: (BrButton new
				 aptitude: BrGlamorousButtonWithLabelAptitude;
				 label: 'Merge';
				 action: [ :aButton | aButton phlow spawnObject: merge ]) ].

	(self outgoingCommits size > 0 and: [ 
		 self outgoingCommits first = item ]) ifTrue: [ 
		container addChild: (BrButton new
				 aptitude: BrGlamorousButtonWithIconAndLabelAptitude;
				 label: self outgoingCommits size asString;
				 icon: BrGlamorousVectorIcons up;
				 action: [ :aButton | 
					 self push.
					 aButton phlow fireUpdateWish ]) ].
	"(self outgoingCommits size > 1 and: [ 
		 self outgoingCommits first = item ]) ifTrue: [ 
		container addChild: (BrButton new
				 aptitude: BrGlamorousButtonWithLabelAptitude;
				 label: 'Squash';
				 action: [ :aButton | 
					 self squash.
					 aButton phlow fireUpdateWish ]) ]."

	(self incomingCommits size > 0 and: [ 
		 self incomingCommits first = item ]) ifTrue: [ 
		container addChild: (BrButton new
				 aptitude: BrGlamorousButtonWithIconAndLabelAptitude;
				 label: self incomingCommits size asString;
				 icon: BrGlamorousVectorIcons down;
				 action: [ :aButton | 
					 self pull.
					 aButton phlow fireUpdateWish ]) ].
	^ container constraintsDo: [ :c | c horizontal matchParent ]
]

{ #category : #accessing }
GtGitRepository >> gtCommitsFor: aView [

	<gtView>
	<gtRepositoryView>
	self repository repositoryDirectory ifNil: [ ^ aView empty ].

	^ aView columnedList
		  title: 'Commits' translated;
		  priority: 2;
		  items: [ 
			  self repository head commits , self incomingCommits 
				  sortDescending: #timeStamp ];
		  column: 'Status' stencil: [ :item | 
			  ((self incomingCommits contains: [ :aCommit | aCommit = item ])
				   ifTrue: [ 
					   (self conflictingCommits contains: [ :aCommit | 
							    aCommit = item ])
						   ifTrue: [ 
							   self
								   statusElementColored:
									   BrGlamorousColors errorBackgroundColor
								   withTooltip: 'Conflict' ]
						   ifFalse: [ 
							   self
								   statusElementColored:
									   BrGlamorousColors successBackgroundColor
								   withTooltip: 'Incoming' ] ]
				   ifFalse: [ 
					   (self outgoingCommits contains: [ :aCommit | aCommit = item ])
						   ifTrue: [ 
							   self
								   statusElementColored:
									   BrGlamorousColors selectedListItemColor
								   withTooltip: 'Outgoing' ]
						   ifFalse: [ BlElement new ] ])
				  size: 12 @ 12;
				  geometry: (BlRoundedRectangleGeometry cornerRadius: 6);
				  margin: (BlInsets left: 15) ]
		  width: 40;
		  column: 'Timestamp'
		  text: [ :aCommit | aCommit timeStamp asStringYMDHM ]
		  width: 120;
		  column: 'Commit' text: #shortId width: 70;
		  column: 'Author' text: #author width: 100;
		  column: 'Description' text: #comment;
		  column: 'Actions' stencil: [ :item | self gtCommitButtonsFor: item ]
		  width: 150;
		  itemContextMenuStencil: [ :element :item | 
			  BrGlamorousSimpleContextMenuContent new
				  items: { ('Revert' -> [ :e | 
						   item revert.
						   self rawCommit: 'Revert ' , item shortId , ' ' , item comment.
						   element phlow fireUpdateWish ]) };
				  yourself ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtPackagesFor: aView context: aContext [
	<gtView>
	<gtRepositoryView>
	self hasWorkingCopy ifFalse: [ ^ aView empty ].
	^ self repository workingCopy gtPackagesFor: aView
]

{ #category : #accessing }
GtGitRepository >> gtRepositoryDirectoryFor: aView [
	<gtView>
	<gtRepositoryView>
	^ (self repository gtRepositoryDirectoryFor: aView) priority: 40
]

{ #category : #'api - testing' }
GtGitRepository >> hasChanges [
	^ self hasWorkingCopy and: [ 
		self isModified "and: [  
			self workingCopy diffToReferenceCommit treeToShow children isNotEmpty ]" ]
]

{ #category : #'api - testing' }
GtGitRepository >> hasRepository [
	^ self repository isNotNil
]

{ #category : #'api - testing' }
GtGitRepository >> hasWorkingCopy [
	^ self hasRepository and: [ self repository workingCopy isNotNil ]
]

{ #category : #'api - repository' }
GtGitRepository >> headDescription [
	^ self repository ifNotNil: #headDescription ifNil: [ '<missing>' ]
]

{ #category : #accessing }
GtGitRepository >> incomingCommits [

	^ self isCommittable
		  ifTrue: [ self repository incomingCommits ]
		  ifFalse: [ #(  ) ]
]

{ #category : #initialization }
GtGitRepository >> initialize [
	super initialize.
	announcer := Announcer new.
	isSubscribed := false.
]

{ #category : #accessing }
GtGitRepository >> isCommittable [

	^ (((self hasWorkingCopy and: [ self repository isMissing not ]) 
		    and: [ 
			    self repository workingCopy workingCopyState
				    isUnknownCommitState not ]) and: [ 
		   self repository workingCopy isDetached not ]) and: [ 
		  self repository head isDetached not ]
]

{ #category : #accessing }
GtGitRepository >> isMissing [
	^ self repository isMissing
]

{ #category : #'api - testing' }
GtGitRepository >> isModified [
	^ (self repository isModified or: [ self repository isDirty ]) or: [ self lepiterWorkingCopy changesToHeadUsingIndex isNotEmpty ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> lepiterWorkingCopy [
	^ lepiterWorkingCopy
]

{ #category : #'api - repository' }
GtGitRepository >> name [
	^ self repository ifNotNil: #name ifNil: [ '<missing>' ]
]

{ #category : #'private - announcement handling' }
GtGitRepository >> onRepositoryModifiedAnnouncement: anAnnouncement [
	anAnnouncement repository = self repository ifTrue: [ ^ self ].
	
	self announce: anAnnouncement
]

{ #category : #accessing }
GtGitRepository >> outgoingCommits [

	^ self isCommittable
		  ifTrue: [ self repository outgoingCommits ]
		  ifFalse: [ #(  ) ]
]

{ #category : #printing }
GtGitRepository >> printOn: aStream [
	aStream nextPutAll: self repository name
]

{ #category : #accessing }
GtGitRepository >> pull [
	| res |
	res := self repository pull.
	Iceberg announcer announce:
		(IceRepositoryModified for: self repository).
	^ res
]

{ #category : #accessing }
GtGitRepository >> push [

	| res |
	res := self repository push.
	Iceberg announcer announce:
		(IceRepositoryModified for: self repository).
	^ res
]

{ #category : #accessing }
GtGitRepository >> rawCommit: aCommitMessage [

	| workingCopyDiff |
	self repository
		commitIndexWithMessage: aCommitMessage
		andParents: (self workingCopy workingCopyState referenceCommits reject: [ :each | each isNoCommit ]).
	Iceberg announcer announce:
		(IceRepositoryModified for: self repository)
]

{ #category : #accessing }
GtGitRepository >> remove [
	self repository delete
]

{ #category : #accessing }
GtGitRepository >> repairActions [

	^ GtGitRepairAction subclasses select: [ :sc | 
		  sc iceTipClass isAvailableFor: self repository ]
]

{ #category : #accessing }
GtGitRepository >> repairStencil [

	^ GtGitRepositoryRepairStencil new repository: repository
]

{ #category : #'api - accessing' }
GtGitRepository >> repository [
	^ repository
]

{ #category : #'api - accessing' }
GtGitRepository >> repository: aRepository [

	repository == aRepository ifTrue: [ ^ self ].
	
	repository := aRepository.
		
	lepiterWorkingCopy := GtLepiterWorkingCopy new 
		repository: aRepository; 
		updateDatabases.
]

{ #category : #accessing }
GtGitRepository >> squash [

	| target message |
	^ self notYetImplemented."
	
	target := self repository branch commits detect: [ :commit | 
		          (self outgoingCommits contains: [ :aCommit | 
			           aCommit = commit ]) not ].
			           
	message := Character cr join: (self outgoingCommits collect: #comment).

	self repository repositoryHandle
		resetTo: target libgitCommit
		resetType: LGitResetTypeEnum git_reset_soft
		checkoutOptions: LGitCheckoutOptions defaults.
		
	self rawCommit: message."
]

{ #category : #accessing }
GtGitRepository >> status [
	^ status ifNil: [ status := (IceTipRepositoryModel on: self repository) status ]
]

{ #category : #accessing }
GtGitRepository >> statusElementColored: aColor withTooltip: aString [

	^ BlElement new
		  background: aColor;
		  aptitude: (BrGlamorousWithLabelTooltipAptitude new text: aString)
]

{ #category : #accessing }
GtGitRepository >> statusModel [

	| conflicting |
	[ 
	| entity statusCollection incoming outgoing |
	entity := self repository.

	entity isMissing ifTrue: [ ^ { GtGitStatusMissing new } ].

	entity workingCopy workingCopyState isUnknownCommitState ifTrue: [ 
		^ { (GtGitStatusUnknownCommitState new message:
			   entity workingCopy workingCopyState description) } ].
	entity workingCopy isDetached ifTrue: [ 
		^ { GtGitStatusDetachedWorkingCopy new } ].
	(entity head isDetached and: [ entity head tags notEmpty ]) ifTrue: [ 
		^ { GtGitStatusDetachedHead new } ].
	entity head isDetached ifTrue: [ ^ { GtGitStatusDetachedHead new } ].

	entity workingCopy project isUnborn ifTrue: [ 
		^ { GtGitStatusNoProject new } ].

	(entity loadedPackages isEmpty and: [ entity packages notEmpty ]) 
		ifTrue: [ ^ { GtGitStatusNotLoaded new } ].

	statusCollection := OrderedCollection new.
	self isModified ifTrue: [ 
		statusCollection add: GtGitStatusUncommittedChanges new ].

	conflicting := self conflictingCommits size.
	conflicting > 0 ifTrue: [ 
		statusCollection add: (GtGitStatusConflicting new count: conflicting) ].

	incoming := self incomingCommits size - conflicting.
	incoming > 0 ifTrue: [ 
		statusCollection add: (GtGitStatusIncoming new count: incoming) ].

	outgoing := self outgoingCommits size.
	outgoing > 0 ifTrue: [ 
		statusCollection add: (GtGitStatusOutgoing new count: outgoing) ].


	^ statusCollection ]
		on: Error
		do: [ :error | 
			^ { (GtGitStatusUnknownError new message: error description) } ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> viewModel [
	^ viewModel ifNil: [ viewModel := GtGitRepositoryViewModel new repositoryModel: self ]
]

{ #category : #'api - repository' }
GtGitRepository >> workingCopy [
	^ self repository workingCopy
]

{ #category : #'gt - extensions' }
GtGitRepository >> workingCopyDiff [
	^ self lepiterWorkingCopy diffToReferenceCommit
]
