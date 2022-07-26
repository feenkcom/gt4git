"
{{gtClass:GtGitRepository}} augments an Iceberg repository with a gt-specific working copy that can handle Lepiter databases and other files. 
It also relies on a gt-specific working copy ({{gtClass:GtLepiterWorkingCopy}}) for peforming operations that afect the state of the image.
"
Class {
	#name : #GtGitRepository,
	#superclass : #Object,
	#traits : 'TGtAnnouncer',
	#classTraits : 'TGtAnnouncer classTrait',
	#instVars : [
		'icebergRepository',
		'announcer',
		'isSubscribed',
		'lepiterWorkingCopy',
		'status',
		'viewModel'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #'instance creation' }
GtGitRepository class >> forClass: aClass [
	^ self forPackage: aClass package
]

{ #category : #'instance creation' }
GtGitRepository class >> forPackage: aPackage [
	| repository |
	
	repository := IceRepository registry detect: [ :aRepo | 
		aRepo workingCopy loadedPackages anySatisfy: [ :icePackage | 
			icePackage package = aPackage name ] ] ifNone: [ nil ].
	^ repository ifNotNil: [ 
		self fromIcebergRepository: repository ]
]

{ #category : #'instance creation' }
GtGitRepository class >> fromIcebergRepository: anIceRepository [
	^ self new 
		icebergRepository: anIceRepository
]

{ #category : #'api - actions adding/removing' }
GtGitRepository >> addBaseline: aBaselineName [

	(RBAddPackageChange addPackageNamed: aBaselineName) execute.
	(RBAddClassChange definition:
		 'BaselineOf subclass: #' , aBaselineName , '
	instanceVariableNames: ''''
	classVariableNames: ''''
	poolDictionaries: ''''
	package: ''' , aBaselineName , '''') execute.
	(RBAddMethodChange
		 compile: 'baseline: spec
	<baseline>'
		 in: aBaselineName asClass
		 classified: #baseline) execute.

	self icebergWorkingCopy addPackageNamed: aBaselineName.
	self announceRepositoryModified.
]

{ #category : #'api - actions adding/removing' }
GtGitRepository >> addNewDatabaseInDirectory: aDirectory [

	self lepiterWorkingCopy addNewDatabaseInDirectory: aDirectory.
	self announceRepositoryModified.
]

{ #category : #announcer }
GtGitRepository >> announceRepositoryModified [
	Iceberg announcer announce:
		(IceRepositoryModified for: self icebergRepository)
]

{ #category : #announcer }
GtGitRepository >> announcer [
	<return: #Announcer>
	^ announcer
]

{ #category : #accessing }
GtGitRepository >> baselines [
	^ ((self icebergWorkingCopy loadedPackages 
		select: [ :aPackage | aPackage isMetacelloBaseline ]) 
		collect: [ :aPackage | aPackage name ]) asOrderedCollection
]

{ #category : #magritte }
GtGitRepository >> baselinesDescription [

	<magritteDescription>
	^ MAToManyRelationDescription new
		  label: 'Baselines';
		  priority: 6;
		  accessor:
			  (MAPluggableAccessor
				   read: #baselines
				   write: [ :aModel :aValue | 
					   aModel baselines
						   removeAllFoundIn: aValue;
						   collect: [ :baseline | self removeBaseline: baseline ].
					   aValue
						   removeAllFoundIn: aModel baselines;
						   collect: [ :baseline | self addBaseline: baseline ] ]);
		  classes: { String };
		  blocListStencil: [ :aMemento :aDescription :aForm | 
			  | aTagger |
			  aTagger := BrTagger new.
			  aTagger
				  margin: ((BlInsets left: 7) withBottom: 4);
				  hMatchParent;
				  vFitContent.
			  aForm hMatchParent.
			  aTagger aptitude: (BrGlamorousTaggerEditableAptitude new
					   margin: (BlInsets right: 5);
					   tagLabel: [ :aTag | 
						   | aLabel |
						   aLabel := BrEditableLabel new
							             text: aTag name;
							             aptitude: (BrGlamorousEditableLabelAptitude new
									              glamorousCodeFont;
									              defaultForeground: Color black;
									              fontSize: 10).

						   (GtCompletionController
							    on: aLabel
							    strategy: GtClassesCompletionStrategy new) install.

						   aLabel
							   whenKey: BlKeyCombination primaryB
							   labelDo: [ :aShortcutEvent :aShortcut | 
								   aTagger phlow spawnTool:
									   (GtMethodCoderTool compiledMethod:
										    (aTag name asClass methodDict at: #baseline:)) ].

						   aLabel ]).
			  aTagger when: BrTaggerAddTagRequest do: [ :aRequest | 
				  aMemento
					  write: ((aTagger tags collect: #name)
							   add: aRequest tag name;
							   yourself)
					  using: aDescription ].
			  aTagger when: BrTaggerRemoveTagRequest do: [ :aRequest | 
				  aMemento
					  write: ((aTagger tags collect: #name)
							   remove: aRequest tag name;
							   yourself)
					  using: aDescription ].
			  aTagger withAsyncSinkDo: [ :anElementSink | 
				  anElementSink
					  sink: AsyncPeakSink new;
					  whenUpdate: [ :theTagger :aSink | 
						  | theValues theTexts |
						  theValues := aSink value currentValue.
						  theTexts := theValues collect: [ :each | 
								              aDescription displayStringFor: each ].
						  theTagger namedTags: theTexts ].
				  (aMemento readObservableValueUsing: aDescription) observe:
					  anElementSink ] ]
]

{ #category : #magritte }
GtGitRepository >> branchDescription [

	<magritteDescription>
	^ MAStringDescription new
		  label: 'Branch';
		  priority: 1;
		  accessor: (MAPluggableAccessor
				   read: [ :aModel | aModel repository branchName ]
				   write: [ :aModel :aValue | 
					   aModel repository checkoutBranch: aValue ]);
		  blocCompletion: [ 
			  GtStringsCompletionStrategy new completions:
					  (GtPrefixTree withAll:
							   (icebergRepository allBranches collect: [ :branch | branch name ])) ];
		  blocStencil: self defaultMagritteStencil;
		  addCondition: [ :aValue | (aValue includesSubstring: '..') not ]
		  labelled: 'May not contain ".."';
		  addCondition: [ :aValue | (aValue includesAny: '~^:?*[\') not ]
		  labelled: 'May not contain any of "~^:?*[\"';
		  addCondition: [ :aValue | (aValue endsWith: '.') not ]
		  labelled: 'May not end with a dot';
		  addCondition: [ :aValue | 
			  ((aValue beginsWith: '/') or: [ aValue endsWith: '/' ]) not ]
		  labelled: 'May not start or end with a slash';
		  addCondition: [ :aValue | (aValue includesSubstring: '@{') not ]
		  labelled: 'May not contain the sequence "@{"';
		  addCondition: [ :aValue | (aValue = '@') not ]
		  labelled: 'May not just be an "@" charater';
		  addCondition: [ :aValue | (aValue includesSubstring: '//') not ]
		  labelled: 'May not contain multiple consecutive slashes';
		  comment:
		  'A branch name. If you set it to a non-existant branch, a new one will be created.'
]

{ #category : #'api - repository' }
GtGitRepository >> changes [
	^ self isModified
		ifTrue: [ self icebergWorkingCopy diffToReferenceCommit treeToShow children ]
		ifFalse: [ Array empty ]
]

{ #category : #magritte }
GtGitRepository >> codeDirectoryDescription [

	<magritteDescription>
	^ MADirectoryDescription new
		  label: 'Code Directory';
		  priority: 4;
		  kind: AbstractFileReference;
		  display: #pathString;
		  accessor: (MAPluggableAccessor
				   read: [ :aModel | 
					   aModel repository codeDirectory asFileReference ]
				   write: [ :aModel :aValue | 
					   icebergRepository codeDirectory:
							   (aValue relativeTo: icebergRepository repositoryDirectory)
								   pathString ])
]

{ #category : #accessing }
GtGitRepository >> conflictingCommits [

	| index commits currentIncomingCommits |
	currentIncomingCommits := self incomingCommits.
	currentIncomingCommits ifEmpty: [ ^ OrderedCollection new ].
	index := 1.
	
	commits := OrderedCollection new.
	[ 
	 index <= currentIncomingCommits size 
	 	and: [ (IceMerge new
			 repository: self icebergRepository;
		 	mergeCommit: (currentIncomingCommits at: index)) hasConflicts ]
	] whileTrue: [ 
		commits add: (currentIncomingCommits at: index).
		index := index + 1 ].
	^ commits
]

{ #category : #'gt - extensions' }
GtGitRepository >> contextMenuOptionsFor: anIceNode [
	| options |
	
	options := { } asOrderedCollection.
	(anIceNode value definition isKindOf: IceCodeDefinition) ifTrue: [
		options add: ('Revert changes' -> [ :e | 
	            self icebergWorkingCopy diffToReferenceCommit revertChanges:
		            anIceNode ]) ].
	anIceNode value canBeBrowsed ifTrue: [ 
		options addFirst: 'Browse' -> [ :e | 
			e phlow spawnTool: (anIceNode value definition toolIn: self) ] ].
	^ options
]

{ #category : #accessing }
GtGitRepository >> databases [
	^ self lepiterWorkingCopy databases
]

{ #category : #magritte }
GtGitRepository >> databasesDescription [

	<magritteDescription>
	^ MAToManyRelationDescription new
		  label: 'Databases';
		  priority: 5;
		  classes: { 
				  LeDatabase.
				  FileLocator };
		  accessor: (MAPluggableAccessor
				   read: [ :aModel | aModel databases asOrderedCollection ]
				   write: [ :aModel :aValue | 
					   aModel databases asOrderedCollection
						   removeAllFoundIn: aValue;
						   collect: [ :database | 
								self lepiterWorkingCopy unloadDatabase: database ].
					   aValue
						   removeAllFoundIn: aModel databases;
						   collect: [ :database | 
							   self addNewDatabaseInDirectory: database ] ]);
		  blocListStencil: [ :aMemento :aDescription :aForm | 
			  | aTagger |
			  aTagger := BrTagger new.
			  aTagger
				  margin: ((BlInsets left: 7) withBottom: 4);
				  hMatchParent;
				  vFitContent.
			  aForm hMatchParent.
			  aTagger aptitude: (BrGlamorousTaggerEditableDropdownAptitude new
					   margin: (BlInsets right: 5);
					   tagLabel: [ :aTag | 
						   BrEditableLabel new
							   text: (aDescription displayStringFor: aTag name);
							   aptitude: (BrGlamorousEditableLabelAptitude new
									    glamorousCodeFont;
									    defaultForeground: Color black;
									    fontSize: 10);
							   whenKey: BlKeyCombination primaryB
							   labelDo: [ :aShortcutEvent :aShortcut | 
							   aTagger phlow spawnObject: aTag name ] ];
					   content: [ :aDropdown :_ | 
						   BrFileSelector new
							   folder: self repository repositoryDirectory;
							   fileFilterBlock: [ :aFile | aFile isDirectory ];
							   okAction: [ :aDirectory :aButton | 
								   aDirectory isDirectory ifTrue: [ 
										   aDropdown fireEvent: BrDropdownHideWish new.
										   aMemento
											   write: ((aTagger tags collect: #name)
													    add: aDirectory;
													    yourself)
											   using: aDescription.
										   aDropdown phlow fireUpdateWish ] ];
							   buttonLabel: 'Add database';
							   padding: (BlInsets all: 20);
							   matchParent ]).
			  aTagger when: BrTaggerAddTagRequest do: [ :aRequest | 
				  aMemento
					  write: ((aTagger tags collect: #name)
							   add: aRequest tag name;
							   yourself)
					  using: aDescription ].
			  aTagger when: BrTaggerRemoveTagRequest do: [ :aRequest | 
				  aMemento
					  write: ((aTagger tags collect: #name)
							   remove: aRequest tag name;
							   yourself)
					  using: aDescription ].
			  aTagger withAsyncSinkDo: [ :anElementSink | 
				  anElementSink
					  sink: AsyncPeakSink new;
					  whenUpdate: [ :theTagger :aSink | 
						  | theValues |
						  theValues := aSink value currentValue.
						  theTagger namedTags: theValues ].
				  (aMemento readObservableValueUsing: aDescription) observe:
					  anElementSink ] ]
]

{ #category : #magritte }
GtGitRepository >> defaultMagritteStencil [

	^ [ :aMemento :aDescription | 
	  | anEditor |
	  anEditor := BrEditor new.
	  aDescription isReadOnly ifTrue: [ anEditor beReadOnlyWithSelection ].
	  anEditor
		  aptitude:
			  (BrGlamorousRegularEditorAptitude new glamorousCodeFont 
				   fontSize: 10);
		  addAptitude: (BrStyleCommonAptitude new
				   default: [ :aStyle | 
					   aStyle background: BrGlamorousColors backdropColor ];
				   focused: [ :aStyle | 
					   aStyle
						   background: Color white;
						   border:
							   (BlBorder
								    paint: BrGlamorousColors focusedEditorBorderColor
								    width: 1) ]);
		  geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
		  vFitContent;
		  hFitContentLimited;
		  margin: (BlInsets all: 4);
		  constraintsDo: [ :c | 
			  c grid vertical alignCenter.
			  c minWidth: 20 ];
		  withAsyncSinkDo: [ :anElementSink | 
			  anElementSink
				  sink: AsyncPeakSink new;
				  whenUpdate: [ :theEditor :aSink | 
					  theEditor text: aSink value currentValue ].
			  (aMemento readObservableValueUsing: aDescription) observe:
				  anElementSink ].

	  anEditor editor when: BrTextEditorModifiedEvent do: [ :anEvent | 
		  aMemento write: anEvent text asString using: aDescription ].

	  anEditor ]
]

{ #category : #'api - actions' }
GtGitRepository >> executeCommit: aCommitMessage [
	| workingCopyDiff |
	
	workingCopyDiff := self workingCopyDiff.
	self icebergWorkingCopy
		commitChanges: workingCopyDiff
		withMessage: aCommitMessage
		force: false.
	
	self announceRepositoryModified.
]

{ #category : #'api - actions' }
GtGitRepository >> executeCommit: aCommitMessage withChanges: changes [
	| workingCopyDiff |
	
	workingCopyDiff := self workingCopyDiff.
	self icebergWorkingCopy
		commitChanges: (workingCopyDiff copyWithOnly: changes)
		withMessage: aCommitMessage
		force: false.
	
	self announceRepositoryModified.
]

{ #category : #'api - actions' }
GtGitRepository >> fetch [
	self icebergRepository fetch.
	self announceRepositoryModified.
]

{ #category : #magritte }
GtGitRepository >> fileFormatDescription [

	<magritteDescription>
	^ MASingleOptionDescription new
		  label: 'File Format';
		  priority: 3;
		  display: [ :aWriter | 
			aWriter 
				ifNil: [ '<unspeficied>' ] 
				ifNotNil: [ aWriter description ]  ];
		  accessor: (MAPluggableAccessor
				   read: [ :aModel | 
					   icebergRepository project isUnborn
							ifTrue: [ nil ] 
							ifFalse: [ icebergRepository project repositoryProperties fileFormat ] ]
				   write: [ :aModel :aValue | 
					   icebergRepository project fileFormat: (aValue = 'Tonel'
								    ifTrue: [ IceLibgitTonelWriter ]
								    ifFalse: [ IceLibgitFiletreeWriter ]).
					   Iceberg announcer announce:
							   (IceRepositoryModified for: icebergRepository) ]);
		  options: { 
				  IceLibgitTonelWriter.
				  IceLibgitFiletreeWriter }
]

{ #category : #'api - actions' }
GtGitRepository >> forget [
	self icebergRepository forget
]

{ #category : #'api - repository' }
GtGitRepository >> getDeltasForFullDiff [
	^ self icebergRepository getDeltasForFullDiff
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtActionFetchFor: anAction [
	<gtAction>
	^ anAction button
		label: 'Fetch';
		priority: 2;
		action: [ :aButton |
			(IceTipRepositoryModel on: self icebergRepository) fetch.
			self announceRepositoryModified.
			aButton phlow fireUpdateWish ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtActionPullFor: anAction [
	<gtAction>
	
	(IceTipRepositoryModel on: self icebergRepository) isDetached ifTrue: [ 
		^ anAction noAction ].
	
	^ anAction button
		  label: 'Pull';
		  priority: 3;
		  action: [ :aButton | 
			  [ self gtLepiterAwarePull ]
				  on: IceMergeResolutionRequest
				  do: [ :r | aButton phlow spawnObject: r merge ].
			  aButton phlow fireUpdateWish ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtActionPushFor: anAction [
	<gtAction>
	
	(IceTipRepositoryModel on: self icebergRepository) isDetached 
		ifTrue: [ ^ anAction noAction ].
	
	^ anAction button
		label: 'Push';
		priority: 4;
		action: [ :aButton | 
			self icebergRepository push.
			self announceRepositoryModified.
			
			aButton phlow fireUpdateWish ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtActionRefreshFor: anAction [
	<gtAction>
	^ anAction button
		label: 'Refresh';
		priority: 1;
		action: [ :aButton |
		
			"Aim to only recalculate the dirty flag for packages that are marked as dirty.
			We skip packages that are not marked as dirty."

			| diff dirtyPackages |
			self icebergRepository isModified ifTrue: [ 
				"If the repository is not marked as modified no action is needed here"


				"We compite the diff but only recalculate the status for dirty packages"
				diff := IceDiff new
					sourceVersion: self icebergRepository workingCopy;
					targetVersion: self icebergRepository workingCopy referenceCommit;
					buildFull.
		
				dirtyPackages := self icebergRepository loadedPackages 
					select: [ :each | each isDirty ].
				dirtyPackages do: [ :each |
					each beDirty: (diff includesPackageNamed: each name) ].
					self announceRepositoryModified. ]. 
				
			aButton phlow fireUpdateWish ]. 
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtActionRepairFor: anAction [
	<gtAction>
	(GtGitRepairAction subclasses 
		select: [:sc | sc iceTipClass isAvailableFor: icebergRepository]) size = 0 
			ifTrue: [ ^ anAction noAction ].
	^ anAction dropdown
		label: 'Repair';
		content: [:aDropdown | 
			GtGitRepositoryRepairStencil new repository: icebergRepository; dropdown: aDropdown ].
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtAllLoadedExamples [
	^ self lepiterWorkingCopy gtAllLoadedExamples
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtChangesFor: aView context: aContext [
	<gtView>
	<gtRepositoryView>
	
	| aViewModel changes chosen |
	chosen := Set new.

	 (self isMissing  
		or: [ self workingCopy isDetached not
			and: [ self icebergRepository head isDetached not
				and: [ self workingCopy project isUnborn ] ] ]) ifTrue: [ ^ aView empty ].

	aViewModel := self viewModel.

	self lepiterWorkingCopy ifNil: [ ^ aView empty ].
	changes := self workingCopyDiff treeToShow.
	(changes isNil or: [ changes isEmpty ]) ifTrue: [ 
		self repository isModified ifTrue: [ self refreshDirtyPackages ].
		^ aView empty ].

	changes do: [ :change | 
		change value hasChanges ifTrue: [ chosen add: change ] ].

	^ aView tree
		  title: 'Changes';
		  items: [ changes children ];
		  children: #children;
		  expandUpTo: 3;
		  priority: 1;
		  stencil: [ :anIceNode | 
			  | element contextMenuOptions |
			  contextMenuOptions := self contextMenuOptionsFor: anIceNode.
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
								              items: contextMenuOptions;
								              yourself ]).
			  anIceNode value hasChanges ifTrue: [ 
				  element addChild: (BrCheckbox new
						   aptitude: BrGlamorousCheckboxAptitude
							   +
								   (BrGlamorousWithLabelTooltipAptitude new text:
										    'Select for Commit');
						   checked: true;
						   whenCheckedDo: [ chosen add: anIceNode value ];
						   margin: (BlInsets right: 8);
						   whenUncheckedDo: [ 
							   chosen remove: anIceNode value ifAbsent: [  ] ]) ].
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
			  | editor button saveAction |
			  editor := BrEditor new
				            aptitude: BrGlamorousRegularEditorAptitude;
				            text: aViewModel commitMessage;
				            hMatchParent;
				            vFitContentLimited;
				            requestFocus.
			  editor selecter
				  all;
				  select.

			  saveAction := [ 
			                aViewModel
				                executeCommit: editor editor text asString
				                withChanges: chosen.
			                button disable.
			                aDropdown enqueueTask:
				                (BlTaskAction new action: [ 
					                 aDropdown dispatchEvent:
						                 (BrDropdownHideWish new anchor: aDropdown) ]).
			                aDropdown phlow fireUpdateWish ].

			  editor addEditorShortcut: (BlShortcutWithAction new
					   combination: BlKeyCombination primaryS;
					   action: saveAction).

			  button := BrButton new.
			  button
				  aptitude: BrGlamorousButtonWithIconAptitude;
				  icon: BrGlamorousVectorIcons accept;
				  label: 'Commit';
				  disabled: editor text isEmpty;
				  action: saveAction.

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

{ #category : #'gt - extensions' }
GtGitRepository >> gtCommitButtonsFor: item withConflicts: conflicts [
	| container merge |
	container := BrHorizontalPane new
			vExact: 24;
			hMatchParent.

	(conflicts contains: [ :aCommit | aCommit = item ])
		ifTrue: [ container
				addChild: (BrButton new
						aptitude: BrGlamorousButtonWithLabelAptitude;
						label: 'Merge';
						action: [ :aButton | aButton phlow spawnObject: merge ]) ].

	(self viewModel outgoingCommits size > 0
		and: [ self viewModel outgoingCommits first = item
				and: [ self repository remotes isNotEmpty ] ])
		ifTrue: [ container
				addChild: (BrButton new
						aptitude: BrGlamorousButtonWithIconAndLabelAptitude;
						label: self viewModel outgoingCommits size asString;
						icon: BrGlamorousVectorIcons up;
						action: [ :aButton | 
							self push.
							aButton phlow fireUpdateWish ]) ].

	(self incomingCommits size > 0
		and: [ self incomingCommits first = item and: [ self repository remotes isNotEmpty ] ])
		ifTrue: [ container
				addChild: (BrButton new
						aptitude: BrGlamorousButtonWithIconAndLabelAptitude;
						label: self incomingCommits size asString;
						icon: BrGlamorousVectorIcons down;
						action: [ :aButton | 
							self pull.
							aButton phlow fireUpdateWish ]) ].
	^ container
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtCommitsFor: aView [
	<gtView>
	<gtRepositoryView>
	| conflicts |
	self isMissing ifTrue: [ ^ aView empty ].

	conflicts := self conflictingCommits.

	^ aView columnedList
		title: 'Commits' translated;
		priority: 2;
		items: [ (AsyncSequenceStream forCollection: self incomingCommits)
				merge: self repository head commitStream ];
		column: 'Status'
			stencil: [ :item | 
				((self incomingCommits contains: [ :aCommit | aCommit = item ])
					ifTrue: [ (conflicts contains: [ :aCommit | aCommit = item ])
							ifTrue: [ self
									statusElementColored: BrGlamorousColors errorBackgroundColor
									withTooltip: 'Conflict' ]
							ifFalse: [ self
									statusElementColored: BrGlamorousColors successBackgroundColor
									withTooltip: 'Incoming' ] ]
					ifFalse: [ (self viewModel outgoingCommits
							contains: [ :aCommit | aCommit = item ])
							ifTrue: [ self
									statusElementColored: BrGlamorousColors selectedListItemColor
									withTooltip: 'Outgoing' ]
							ifFalse: [ BlElement new ] ])
					size: 12 @ 12;
					geometry: (BlRoundedRectangleGeometry cornerRadius: 6);
					margin: (BlInsets left: 15) ]
			width: 40;
		column: 'Timestamp'
			text: [ :aCommit | aCommit timeStamp asStringYMDHM ]
			width: 120;
		column: 'Commit'
			text: #shortId
			width: 70;
		column: 'Author'
			text: #author
			width: 100;
		column: 'Description' text: #comment;
		column: 'Actions'
			stencil: [ :item | self gtCommitButtonsFor: item withConflicts: conflicts ]
			width: 150;
		send: [:each | GtGitCommit new
			id: each id;
			author: each author;
			datetime: each datetime;
			ancestorIds: each ancestorIds;
			comment: each comment;
			repository: each repository;
			lepiterWorkingCopy: self lepiterWorkingCopy
			yourself ];
		itemContextMenuStencil: [ :element :item | 
			BrGlamorousSimpleContextMenuContent new
				items: {'Revert'
							-> [ :e | 
								item revert.
								self rawCommit: 'Revert ' , item shortId , ' ' , item comment.
								element phlow fireUpdateWish ].
						'Checkout'
							-> [ :e | 
								item checkout.
								self announceRepositoryModified.
								element phlow fireUpdateWish ]};
				yourself ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtExamplesFor: aView [
	<gtView>
	<gtRepositoryView>
	
	^ aView forward 
		title: 'Examples';
		priority: 20;
		object: [ GtExampleGroup withAll: self gtAllLoadedExamples];
		view: #gtExamplesFor:
]

{ #category : #'api - actions' }
GtGitRepository >> gtLepiterAwareCheckoutBranch: aBranchName [ 
	self icebergRepository 
		gtLepiterAwareCheckoutBranch: aBranchName 
		withWorkingCopy: self lepiterWorkingCopy
]

{ #category : #accessing }
GtGitRepository >> gtLepiterAwarePull [
	self icebergRepository configureUpstreamIfNecessary.
	self icebergRepository gtPullInWorkingCopy: self lepiterWorkingCopy.


	self announceRepositoryModified
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtPackagesFor: aView context: aContext [
	<gtView>
	<gtRepositoryView>
	self hasWorkingCopy ifFalse: [ ^ aView empty ].
	^ self icebergWorkingCopy gtPackagesFor: aView
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtReadmeFor: aView context: aContext [

	<gtView>
	<gtRepositoryView>
	| readme |
	(self hasWorkingCopy not or: [ self icebergRepository isMissing ]) ifTrue: [ 
		^ aView empty ].

	readme := self icebergRepository repositoryDirectory / 'README.md'.

	^ aView explicit
		  title: 'README';
		  priority: 2;
		  stencil: [ 
			  | snippet snippetViewModel |
			  snippet := LeTextSnippet string: (readme exists
						              ifTrue: [ readme contents ]
						              ifFalse: [ '' ]).
			  snippetViewModel := snippet asSnippetViewModel.
			  snippetViewModel coderViewModel addShortcut:
					  (BrEditorShortcut lineEnding combination:
							   (LeSnippetElement keyboardShortcut: #NewLine)).
			  snippetViewModel coderViewModel addShortcut: (BlShortcutWithAction new
						   combination: BlKeyCombination primaryS;
						   action: [ :anEvent | 
							   readme writeStreamDo: [ :s | 
									   s truncate.
									   s nextPutAll: anEvent currentTarget text asString ].
							   self repository addFileToIndex: 'README.md'.
							   self announceRepositoryModified. ]).
			  ((snippetViewModel snippetView needsEmbellishments: false)
				   asElement snippetViewModel: snippetViewModel) vMatchParent ];
		  actionButtonIcon: BrGlamorousVectorIcons accept
		  tooltip: 'Save README'
		  action: [ :aToggle :aTab | 
			  readme writeStreamDo: [ :s | 
				  s truncate.
				  s nextPutAll:
					  aTab viewContentElement children first text asString ].
			  self repository addFileToIndex: 'README.md'.
			  self announceRepositoryModified. ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtRepositoryDirectoryFor: aView [
	<gtView>
	<gtRepositoryView>
	
	^ aView forward 
		title: 'Repository directory';
		priority: 40;
		object: [ self icebergRepository ];
		view: #gtRepositoryDirectoryFor:
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtUnbornHelpFor: aView [
	<gtView>
	<gtRepositoryView>
	self workingCopy project isUnborn ifFalse: [ ^ aView empty ].


	(GtGitRepairAction subclasses
		select: [ :sc | sc iceTipClass isAvailableFor: icebergRepository ]) size = 0
		ifTrue: [ ^ aView empty ].

	^ aView explicit
		title: 'Setup';
		priority: 1;
		stencil: [ | container |
			container := BrVerticalPane new matchParent padding: (BlInsets all: 5).

			container
				addChild: (BrEditor new
						aptitude: BrGlamorousRegularEditorAptitude new;
						vFitContent;
						text: 'The repository is not set up for use with GT yet. You will need to perform the following actions before committing:'
								asRopedText).

			(GtGitRepairAction subclasses
				select: [ :sc | sc iceTipClass isAvailableFor: icebergRepository ])
				do: [ :sc | container addChild: (sc new repository: icebergRepository) repairStencil ].
			container ]
]

{ #category : #'api - testing' }
GtGitRepository >> hasChanges [
	^ self hasWorkingCopy and: [ 
		self isModified "and: [  
			self workingCopy diffToReferenceCommit treeToShow children isNotEmpty ]" ]
]

{ #category : #'api - testing' }
GtGitRepository >> hasRepository [
	^ self icebergRepository isNotNil
]

{ #category : #'api - testing' }
GtGitRepository >> hasWorkingCopy [
	^ self hasRepository and: [ self icebergRepository workingCopy isNotNil ]
]

{ #category : #'api - repository' }
GtGitRepository >> headDescription [
	^ self icebergRepository ifNotNil: #headDescription ifNil: [ '<missing>' ]
]

{ #category : #'api - accessing' }
GtGitRepository >> icebergRepository [
	^ icebergRepository
]

{ #category : #'api - accessing' }
GtGitRepository >> icebergRepository: anIcebergRepository [

	icebergRepository == anIcebergRepository ifTrue: [ ^ self ].

	icebergRepository := anIcebergRepository makeSafe.

	lepiterWorkingCopy := GtLepiterWorkingCopy new
		icebergRepository: anIcebergRepository;
		updateDatabases
]

{ #category : #'api - accessing' }
GtGitRepository >> icebergWorkingCopy [
	^ self icebergRepository workingCopy
]

{ #category : #'api - repository' }
GtGitRepository >> incomingCommits [

	^ self isCommittable
		  ifTrue: [ self icebergRepository incomingCommits ]
		  ifFalse: [ #() ]
]

{ #category : #initialization }
GtGitRepository >> initialize [
	super initialize.
	announcer := Announcer new.
	isSubscribed := false.
]

{ #category : #'api - testing' }
GtGitRepository >> isCommittable [

	^ self hasWorkingCopy and: [ self icebergRepository isMissing not  
		    and: [ 
			    self icebergRepository workingCopy workingCopyState
				    isUnknownCommitState not   and: [ 
		   self icebergRepository workingCopy isDetached not    and: [ 
		  self icebergRepository head isDetached not ] ] ] ]
]

{ #category : #'api - testing' }
GtGitRepository >> isMissing [
	^ self icebergRepository isMissing
]

{ #category : #'api - testing' }
GtGitRepository >> isModified [

	^ (self icebergRepository isModified or: [ 
		   self lepiterWorkingCopy hasDatabases and: [ 
			   self icebergRepository isDirty ] ]) or: [ 
		  self lepiterWorkingCopy changesToHeadUsingIndex isNotEmpty ]
]

{ #category : #'gt - extensions' }
GtGitRepository >> lepiterWorkingCopy [
	^ lepiterWorkingCopy
]

{ #category : #'api - accessing' }
GtGitRepository >> lepiterWorkingCopy: aLepiterWorkingCopy [
	lepiterWorkingCopy := aLepiterWorkingCopy
]

{ #category : #'api - repository' }
GtGitRepository >> name [
	^ self icebergRepository ifNotNil: #name ifNil: [ '<missing>' ]
]

{ #category : #'private - announcement handling' }
GtGitRepository >> onRepositoryModifiedAnnouncement: anAnnouncement [
	anAnnouncement repository = self icebergRepository ifTrue: [ ^ self ].
	
	self announce: anAnnouncement
]

{ #category : #magritte }
GtGitRepository >> originDescription [

	<magritteDescription>
	^ MAStringDescription new
		  label: 'Origin';
		  priority: 2;
		  blocStencil: self defaultMagritteStencil;
		  accessor: (MAPluggableAccessor
				   read: [ :aModel | aModel repository originUrl ]
				   write: [ :aModel :aValue | 
					   aModel repository setOriginTo: aValue ])
]

{ #category : #'api - repository' }
GtGitRepository >> outgoingCommits [

	^ self isCommittable
		  ifTrue: [ self icebergRepository outgoingCommits ]
		  ifFalse: [ #(  ) ]
]

{ #category : #printing }
GtGitRepository >> printOn: aStream [
	aStream nextPutAll: self icebergRepository name
]

{ #category : #'api - actions' }
GtGitRepository >> pull [
	self icebergRepository configureUpstreamIfNecessary.
	self icebergRepository pull.
	
	self announceRepositoryModified.
]

{ #category : #'api - actions' }
GtGitRepository >> push [
	self icebergRepository configureUpstreamIfNecessary.
	self icebergRepository push.
	
	self announceRepositoryModified.
]

{ #category : #accessing }
GtGitRepository >> rawCommit: aCommitMessage [

	self icebergRepository
		commitIndexWithMessage: aCommitMessage
		andParents: (self icebergWorkingCopy workingCopyState referenceCommits reject: [ :each | each isNoCommit ]).
	self announceRepositoryModified.
]

{ #category : #'gt - extensions' }
GtGitRepository >> refreshDirtyPackages [

	self icebergRepository workingCopy refreshDirtyPackages.
	self icebergRepository isModified ifFalse: [ 
		self announceRepositoryModified. ]
]

{ #category : #'api - actions' }
GtGitRepository >> remove [
	self icebergRepository delete
]

{ #category : #'api - actions adding/removing' }
GtGitRepository >> removeBaseline: aBaseline [

	self icebergRepository workingCopy removePackageNamed: aBaseline.
	self icebergRepository workingCopy refreshPackages.
	self announceRepositoryModified.
]

{ #category : #accessing }
GtGitRepository >> repairActions [

	^ GtGitRepairAction subclasses select: [ :sc | 
		  sc iceTipClass isAvailableFor: self icebergRepository ]
]

{ #category : #accessing }
GtGitRepository >> repairStencil [

	^ GtGitRepositoryRepairStencil new repository: icebergRepository
]

{ #category : #'api - accessing' }
GtGitRepository >> repository [
	^ icebergRepository
]

{ #category : #'api - accessing' }
GtGitRepository >> repository: anIcebergRepository [
	self icebergRepository: anIcebergRepository
]

{ #category : #'api - actions' }
GtGitRepository >> squash [

	^ self notYetImplemented
	
	"| target message |
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
	^ status ifNil: [ status := (IceTipRepositoryModel on: self icebergRepository) status ]
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
	entity := self icebergRepository.

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

{ #category : #'api - accessing' }
GtGitRepository >> workingCopy [
	"In several places this is used as a IceGitRepository.
	That is why this method returns the Iceberg working copy."
	^ self icebergWorkingCopy
]

{ #category : #'api - repository' }
GtGitRepository >> workingCopyDiff [
	^ self lepiterWorkingCopy diffToReferenceCommit
]
