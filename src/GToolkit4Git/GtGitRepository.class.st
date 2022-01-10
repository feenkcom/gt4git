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
		'status'
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

{ #category : #'api - actions' }
GtGitRepository >> fetch [
	self repository fetch.
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
	| aViewModel changes |

	aViewModel := aContext
		at: #repositoryViewModel
		ifAbsentPut: [ GtGitRepositoryViewModel new repositoryModel: self ].
	
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
					  aViewModel executeCommit: editor editor text asString.
					  button disable.
					  aDropdown enqueueTask: (BlTaskAction new action: [ 
									   aDropdown dispatchEvent:
											   (BrDropdownHideWish new anchor: aDropdown).
									   ]).
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
GtGitRepository >> gtCommitsFor: aView [
	<gtView>
	<gtRepositoryView>
	self repository repositoryDirectory ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'Commits';
		object: [ self repository branch ];
		view: #gtCommitsFor:
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
	^ self hasWorkingCopy and: [ self workingCopy isModified ]
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
	super printOn: aStream.
	self repository ifNil: [ ^ self ].
	
	aStream 
		nextPut: $(;
		nextPutAll: self repository name;
		nextPut: $)
]

{ #category : #accessing }
GtGitRepository >> pull [
	^ self repository pull
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
	
	isSubscribed ifTrue: [ ^ self ].
	
	Iceberg announcer weak
		when: IceRepositoryModified
		send: #onRepositoryModifiedAnnouncement:
		to: self.
		
	lepiterWorkingCopy := GtLepiterWorkingCopy new 
		repository: aRepository; 
		updateDatabases.
]

{ #category : #accessing }
GtGitRepository >> status [
	^ status ifNil: [ status := (IceTipRepositoryModel on: self repository) status ]
]

{ #category : #accessing }
GtGitRepository >> statusModel [
	^ (IceTipRepositoryModel on: self repository) statusModel
]

{ #category : #'api - repository' }
GtGitRepository >> workingCopy [
	^ self repository workingCopy
]

{ #category : #'gt - extensions' }
GtGitRepository >> workingCopyDiff [
	^ self lepiterWorkingCopy diffToReferenceCommit
]
