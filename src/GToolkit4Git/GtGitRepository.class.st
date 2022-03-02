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

{ #category : #'instance creation' }
GtGitRepository class >> forClass: aClass [
	^ self forPackage: aClass package
]

{ #category : #'instance creation' }
GtGitRepository class >> forPackage: aPackage [
	| repository |
	repository := IceRepository registry detect: [:aRepo | aRepo workingCopy loadedPackages anySatisfy: [:icePackage | icePackage package = aPackage name ] ] ifNone: [ nil ].
	^ repository ifNotNil: [ self new repository: repository ]
]

{ #category : #accessing }
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

	self repository workingCopy addPackageNamed: aBaselineName.
	Iceberg announcer announce:
		(IceRepositoryModified new repository: self repository)
]

{ #category : #accessing }
GtGitRepository >> addDatabase: aDatabaseName [

	| aDatabase aFileLocator |
	aFileLocator := self repository repositoryDirectory / aDatabaseName.
	aFileLocator createDirectory.
	aDatabase := LeLocalStoreLoad current loadAndMonitorFrom:
		             aFileLocator.

	LeDatabasesRegistry uniqueInstance ensureDatabase addDB: aDatabase.

	LeDatabasesRegistry defaultLogicalDatabase properties 
		addRegisteredDirectory: aFileLocator.

	self repository addFileToIndex:
		(aFileLocator relativeTo: self repository repositoryDirectory).
	self lepiterWorkingCopy addDB: aDatabase.
	Iceberg announcer announce:
		(IceRepositoryModified new repository: self repository)
]

{ #category : #accessing }
GtGitRepository >> addNewDatabaseInDirectory: aDirectory [

	| aDatabase aFileLocator |
	aFileLocator := aDirectory gtWithClosestFileLocatorParent.
	aDatabase := LeLocalStoreLoad current loadAndMonitorFrom:
		             aFileLocator.

	LeDatabasesRegistry uniqueInstance ensureDatabase addDB: aDatabase.

	LeDatabasesRegistry defaultLogicalDatabase properties 
		addRegisteredDirectory: aFileLocator.

	self repository addFileToIndex:
		(aDirectory relativeTo: self repository repositoryDirectory).
	self lepiterWorkingCopy addDB: aDatabase
]

{ #category : #announcer }
GtGitRepository >> announcer [
	<return: #Announcer>
	^ announcer
]

{ #category : #accessing }
GtGitRepository >> baselines [
	^ ((self repository workingCopy loadedPackages select: [:aPackage | aPackage isMetacelloBaseline ]) collect: [:aPackage | aPackage name ]) asOrderedCollection
]

{ #category : #accessing }
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

{ #category : #accessing }
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
							   (repository allBranches collect: [ :branch | branch name ])) ];
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
		ifTrue: [ self workingCopy diffToReferenceCommit treeToShow children ]
		ifFalse: [ Array empty ]
]

{ #category : #accessing }
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
					   repository codeDirectory:
							   (aValue relativeTo: repository repositoryDirectory)
								   pathString ])
]

{ #category : #accessing }
GtGitRepository >> conflictingCommits [

	| index commits |
	self incomingCommits ifEmpty: [ ^ OrderedCollection new ].
	index := 1.
	commits := OrderedCollection new.
	[ 
	(IceMerge new
		 repository: self repository;
		 mergeCommit: (self incomingCommits at: index)) hasConflicts ] 
		whileTrue: [ 
			index := index + 1.
			commits add: (self incomingCommits at: index) ].
	^ commits
]

{ #category : #accessing }
GtGitRepository >> databases [
	^ self lepiterWorkingCopy databases
]

{ #category : #accessing }
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
					   | databasesToAdd databasesToRemove |
					   aModel databases asOrderedCollection
						   removeAllFoundIn: aValue;
						   collect: [ :database | self removeDatabase: database ].
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

{ #category : #accessing }
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
		  | aPromise |
		  aMemento write: anEvent text asString using: aDescription ].

	  anEditor ]
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
GtGitRepository >> fileFormatDescription [

	<magritteDescription>
	^ MASingleOptionDescription new
		  label: 'File Format';
		  priority: 3;
		  display: #description;
		  accessor: (MAPluggableAccessor
				   read: [ :aModel | 
					   repository project repositoryProperties fileFormat ]
				   write: [ :aModel :aValue | 
					   | model |
					   repository project fileFormat: (aValue = 'Tonel'
								    ifTrue: [ IceLibgitTonelWriter ]
								    ifFalse: [ IceLibgitFiletreeWriter ]).
					   Iceberg announcer announce:
							   (IceRepositoryModified for: repository) ]);
		  options: { 
				  IceLibgitTonelWriter.
				  IceLibgitFiletreeWriter }
]

{ #category : #accessing }
GtGitRepository >> forget [
	self repository forget
]

{ #category : #accessing }
GtGitRepository >> gtActionEnhancementsFor: anAction [

	<gtAction>

	^ anAction dropdown
		  label: 'Enhancements';
		  priority: 3;
		  action: [ :aDropdown | 
			  BrVerticalPane new
				  constraintsDo: [ :c | 
					  c frame horizontal alignCenter.
					  c horizontal fitContent.
					  c vertical fitContent ];
				  addChild: (BrButton new
						   aptitude: BrGlamorousButtonWithLabelAptitude;
						   margin: (BlInsets all: 5);
						   label: 'Set source directory');
				  addChild: (BrButton new
						   aptitude: BrGlamorousButtonWithLabelAptitude;
						   margin: (BlInsets all: 5);
						   label: 'Create a baseline')
			  "
											     content: [ 
												     GtGitRepositoryRepairStencil new
													     repository: self repository;
													     dropdown: aDropdown ]);" " element |
												     element := GtPharoCreateBaselineElement new.
												     element behaviorBlock: [ :cls | 
													     self repository workingCopy addPackageNamed:
														     cls package name.
														 Iceberg announcer announce: (IceRepositoryModified new repository: self repository).
													     aDropdown fireEvent: BrDropdownHideWish new ].
												     element forBaselineDefinition ]);" ]
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

{ #category : #accessing }
GtGitRepository >> gtAllLoadedExamples [
	^ self lepiterWorkingCopy gtAllLoadedExamples
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtChangesFor: aView context: aContext [

	<gtView>
	<gtRepositoryView>
	| aViewModel changes chosen |
	chosen := Set new.

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
			  | element |
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
						   whenCheckedDo: [ chosen add: anIceNode value ];
						   margin: (BlInsets right: 8);
						   whenUncheckedDo: [ chosen remove: anIceNode value ifAbsent: [ ] ]) ].
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
				            aptitude: BrGlamorousRegularEditorAptitude;
				            text: aViewModel commitMessage;
				            hMatchParent;
				            vFitContentLimited;
				            requestFocus.
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
GtGitRepository >> gtCommitButtonsFor: item withConflicts: conflicts [

	| container merge |
	container := BlElement new height: 24.

	(conflicts contains: [ :aCommit | aCommit = item ]) ifTrue: [ 
		container addChild: (BrButton new
				 aptitude: BrGlamorousButtonWithLabelAptitude;
				 label: 'Merge';
				 action: [ :aButton | aButton phlow spawnObject: merge ]) ].

	(self viewModel outgoingCommits size > 0 and: [ 
		 self viewModel outgoingCommits first = item ]) ifTrue: [ 
		container addChild: (BrButton new
				 aptitude: BrGlamorousButtonWithIconAndLabelAptitude;
				 label: self viewModel outgoingCommits size asString;
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
	| conflicts |
	self repository repositoryDirectory ifNil: [ ^ aView empty ].

	conflicts := self conflictingCommits.

	^ aView columnedList
		  title: 'Commits' translated;
		  priority: 2;
		  items: [ 
			  self incomingCommits , self repository head commits 
				  sortDescending: #timeStamp ];
		  column: 'Status' stencil: [ :item | 
			  ((self incomingCommits contains: [ :aCommit | aCommit = item ])
				   ifTrue: [ 
					   (conflicts contains: [ :aCommit | aCommit = item ])
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
					   (self viewModel outgoingCommits contains: [ :aCommit | aCommit = item ])
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
		  column: 'Actions'
		  stencil: [ :item | 
		  self gtCommitButtonsFor: item withConflicts: conflicts ]
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
GtGitRepository >> gtExamplesFor: aView [
	<gtView>
	<gtRepositoryView>
	
	^ aView forward 
		title: 'Examples';
		priority: 20;
		object: [ GtExampleGroup withAll: self gtAllLoadedExamples];
		view: #gtExamplesFor:
]

{ #category : #'gt - extensions' }
GtGitRepository >> gtPackagesFor: aView context: aContext [
	<gtView>
	<gtRepositoryView>
	self hasWorkingCopy ifFalse: [ ^ aView empty ].
	^ self repository workingCopy gtPackagesFor: aView
]

{ #category : #accessing }
GtGitRepository >> gtReadmeFor: aView context: aContext [

	<gtView>
	<gtRepositoryView>
	(self hasWorkingCopy not or: [ self repository isMissing ]) 
		ifTrue: [ ^ aView empty ].

	^ aView textEditor
		  title: 'README';
		  priority: 2;
		  text: [ 
			  (self repository repositoryDirectory / 'README.md') contents ];
		  actionButtonIcon: BrGlamorousVectorIcons accept
		  tooltip: 'Save README'
		  action: [ :aToggle :aTab | 
			  self repository repositoryDirectory / 'README.md' writeStreamDo: [ 
					  :s | 
					  s truncate.
					  s nextPutAll:
							  aTab viewContentElement children first text asString ].
			  self repository addFileToIndex: 'README.md'.
			  Iceberg announcer announce:
					  (IceRepositoryModified new repository: self repository) ]
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

	^ (self repository isModified or: [ 
		   self lepiterWorkingCopy hasDatabases and: [ 
			   self repository isDirty ] ]) or: [ 
		  self lepiterWorkingCopy changesToHeadUsingIndex isNotEmpty ]
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
	self repository configureUpstreamIfNecessary.
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

{ #category : #'gt - extensions' }
GtGitRepository >> refreshDirtyPackages [

	self repository workingCopy refreshDirtyPackages.
	self repository isModified ifFalse: [ 
		Iceberg announcer announce:
			(IceRepositoryModified new repository: self repository) ]
]

{ #category : #accessing }
GtGitRepository >> remove [
	self repository delete
]

{ #category : #accessing }
GtGitRepository >> removeBaseline: aBaseline [

	self repository workingCopy removePackageNamed: aBaseline.
	self repository workingCopy refreshPackages.
	Iceberg announcer announce:
		(IceRepositoryModified new repository: self repository)
]

{ #category : #accessing }
GtGitRepository >> removeDatabase: aDatabase [
	aDatabase unload.
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

	repository := aRepository makeSafe.

	lepiterWorkingCopy := GtLepiterWorkingCopy new
		                      repository: aRepository;
		                      updateDatabases
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
