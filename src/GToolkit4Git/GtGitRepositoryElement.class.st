Class {
	#name : #GtGitRepositoryElement,
	#superclass : #BlElement,
	#traits : 'TGtGitWithRepositoryViewModel + TBrLayoutResizable',
	#classTraits : 'TGtGitWithRepositoryViewModel classTrait + TBrLayoutResizable classTrait',
	#instVars : [
		'tabsElement',
		'toolbarElement',
		'labelElement',
		'lazyTabsElement',
		'statusElement',
		'definitionsElement',
		'updater',
		'navigationModel'
	],
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #'instance creation' }
GtGitRepositoryElement class >> on: each [ 
	| aViewModel |
	aViewModel := GtGitRepositoryViewModel new.
	aViewModel repositoryModel: (GtGitRepository fromIcebergRepository: each).
	
	^ self new repositoryViewModel: aViewModel
]

{ #category : #initialization }
GtGitRepositoryElement >> addPackageNamed: aString [ 
	
	self repositoryViewModel addPackage: aString asSymbol
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> createActionsHeaderSeparator [
	^ BrFrame new
		vFitContent;
		hMatchParent;
		viewModel: BrWidgetModel new
]

{ #category : #'building - actions' }
GtGitRepositoryElement >> createFetchRepositoryButton [
	^ BrButton new
		aptitude: BrGlamorousButtonWithIconAptitude;
		icon: BrGlamorousVectorIcons refresh;
		label: 'Fetch';
		action: [ :aButton |
			self repositoryModel executeAsAsyncJob: [ :job |
				job label: 'Fetching...'.
				self fetchAllRepositoriesFrom: aButton ] ]
]

{ #category : #'building - actions' }
GtGitRepositoryElement >> createInspectRepositoryButton [
	^ BrButton new
		aptitude: BrGlamorousButtonWithIconAptitude;
		icon: BrGlamorousVectorIcons inspect;
		label: 'Inspect';
		action: [ :aButton | aButton phlow spawnObject: self repositoryViewModel repositoryModel ]
]

{ #category : #'building - actions' }
GtGitRepositoryElement >> createPullRepositoryWithIncomingCommits: aListOfIncomingCommits [
	| dropdownButton incomingLabel |
	
	incomingLabel := aListOfIncomingCommits size asRopedText.
	
	dropdownButton := BrButton new.
	dropdownButton
		aptitude: BrGlamorousButtonWithIconAndLabelAptitude
			+ (BrGlamorousWithExplicitDropdownAptitude
				handle: [ 
					BrButton new
						aptitude: BrGlamorousButtonWithIconAndLabelAptitude
							- BrGlamorousButtonExteriorAptitude;
						icon: BrGlamorousVectorIcons down;
						label: incomingLabel ]
				content: [ 
					self
						showCommits: aListOfIncomingCommits
						on: dropdownButton
						withAction: [ :aButton |
							self repositoryModel executeAsAsyncJob: [ :job |
								job label: 'Pulling...'.
								self pullFrom: aButton ] ]
						named: 'Pull' ])
				+ (BrGlamorousWithExplicitTooltipAptitude text: 'Pull');
		icon: BrGlamorousVectorIcons down;
		label: incomingLabel.
	^ dropdownButton
]

{ #category : #'building - actions' }
GtGitRepositoryElement >> createPullRepositoryWithNoIncommingCommitsButton [
	^ BrButton new
			aptitude: (BrGlamorousButtonWithIconAndLabelAptitude
				+ (BrGlamorousWithExplicitTooltipAptitude text: 'Pull'));
			icon: BrGlamorousVectorIcons down;
			label: '';
			action: [ :aButton | 
				self repositoryModel executeAsAsyncJob: [ :job |
					job label: 'Pulling...'.
					self pullFrom: aButton ] ]
]

{ #category : #'building - actions' }
GtGitRepositoryElement >> createPushButtonForCommits: aListOfOutgoingCommits [
	| dropdownButton |
	dropdownButton := BrButton new.
	dropdownButton
		aptitude: BrGlamorousButtonWithIconAndLabelAptitude
			+ (BrGlamorousWithExplicitDropdownAptitude
				 handle: [ 
					BrButton new
						aptitude: BrGlamorousButtonWithIconAndLabelAptitude
							- BrGlamorousButtonExteriorAptitude;
						icon: BrGlamorousVectorIcons up;
						label: aListOfOutgoingCommits size asRopedText ]
				content: [ 
					self
						showCommits: aListOfOutgoingCommits
						on: dropdownButton
						withAction: [ :aButton |
							self repositoryModel executeAsAsyncJob: [ :job |
								job label: 'Pushing...'.
								self pushFrom: aButton ] ]
						named: 'Push' ])
			+ (BrGlamorousWithExplicitTooltipAptitude text: 'Push');
		icon: BrGlamorousVectorIcons up;
		label: aListOfOutgoingCommits size asRopedText.
		
	^ dropdownButton
]

{ #category : #'building - actions' }
GtGitRepositoryElement >> createRemoveRepositoryButton [
	| localDelete |
	localDelete := false.

	^ GtPreviewChangeButton new
		icon: BrGlamorousVectorIcons remove;
		label: 'Remove';
		changeAction: [ :aButton | 
			localDelete
				ifTrue: [ self repositoryViewModel remove ]
				ifFalse: [ self repositoryViewModel forget ].
			navigationModel announce: (GtGitRepositorySelected new repository: nil).
			aButton phlow fireToolUpdateWish ];
		changeStencil: [ BrVerticalPane new
				hFitContent;
				vFitContent;
				margin: (BlInsets all: 10);
				addChild: (BrLabel new
						aptitude: BrGlamorousLabelAptitude new glamorousRegularFont;
						text: 'Remove repository?' asRopedText);
				addChild: (BrHorizontalPane new
						hFitContent;
						vFitContent;
						alignCenterLeft;
						margin: (BlInsets top: 5);
						addChild: (BrCheckbox new
									aptitude: BrGlamorousCheckboxAptitude;
									whenCheckedDo: [ localDelete := true ];
									margin: (BlInsets right: 8);
									whenUncheckedDo: [ localDelete := false ])
							as: #'git-repository-removal-checkbox';
						addChild: (BrLabel new
									aptitude: BrLabelAptitude new glamorousRegularFont;
									text: 'Remove repository from disk')) ]
]

{ #category : #'building - actions' }
GtGitRepositoryElement >> createRepairRepositoryButton [
	| dropdownButton buttonLabel |
	dropdownButton := BrButton new.
	buttonLabel := self repositoryViewModel repositoryModel isUninitialized
			ifTrue: [ 'Initialize' ]
			ifFalse: [ 'Repair' ].
	dropdownButton
		aptitude: BrGlamorousButtonWithLabelAptitude
				+ (BrGlamorousWithExplicitDropdownAptitude
						handle: [ BrButton new
								aptitude: BrGlamorousButtonWithLabelAptitude - BrGlamorousButtonExteriorAptitude;
								label: buttonLabel ]
						content: [ self repositoryViewModel repairStencilFor: dropdownButton ]);
		label: buttonLabel.
	^ dropdownButton
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> createRepositoryLabelElement [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new
			bold;
			labelDo: [ :aLabel | 
				aLabel padding: BlInsets empty ]);
		beHugeSize;
		text: ''
]

{ #category : #initialization }
GtGitRepositoryElement >> defaultLayout [
	^ BlLinearLayout vertical
]

{ #category : #initialization }
GtGitRepositoryElement >> definitionsElement [
	^ definitionsElement
]

{ #category : #initialization }
GtGitRepositoryElement >> fetchAllRepositoriesFrom: aButton [ 
	self repositoryViewModel fetch.
	BlTaskAction 
		enqueueElement: aButton 
		action: [ aButton phlow fireToolUpdateWish ]
]

{ #category : #accessing }
GtGitRepositoryElement >> handleAnnouncement: anAnnouncement [

	(self hasRepositoryViewModel not or: [ 
		 self repositoryViewModel hasRepository not ]) ifTrue: [ ^ self ].
	anAnnouncement repository = self repositoryViewModel repositoryModel 
		ifFalse: [ ^ self ]. 

	updater requestUpdate
]

{ #category : #initialization }
GtGitRepositoryElement >> initialize [
	super initialize.
	self initializeToolbarElement.
	self initializeLazyTabsElement.
	self initializeDefinitionsElement.
	
	self addChild: self makeLabel as: #label.
	self addChild: self toolbarElement as: #toolbar.
	self addChild: self definitionsElement as: #definitions.
	self addChild: self lazyTabsElement as: #lazyTabs.
	
	self matchParent.
]

{ #category : #initialization }
GtGitRepositoryElement >> initializeDefinitionsElement [
	definitionsElement := BlElement new
]

{ #category : #initialization }
GtGitRepositoryElement >> initializeLazyTabsElement [
	lazyTabsElement := BlElement new
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ]
]

{ #category : #initialization }
GtGitRepositoryElement >> initializeToolbarElement [

	toolbarElement := BrToolbar new
		aptitude: (BrGlamorousToolbarAptitude new spacing: 0);
		vFitContent;
		hMatchParent;
		margin: (BlInsets bottom: 5)
]

{ #category : #'private - accessing' }
GtGitRepositoryElement >> labelElement [
	^ labelElement
]

{ #category : #'private - accessing' }
GtGitRepositoryElement >> lazyTabsElement [
	^ lazyTabsElement
]

{ #category : #initialization }
GtGitRepositoryElement >> makeLabel [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new glamorousRegularFontAndSize
				foreground: Color gray;
				fontSize: 12);
		text: 'Git Repository'
]

{ #category : #accessing }
GtGitRepositoryElement >> navigationModel: aNavigationModel [
	navigationModel := aNavigationModel
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> newRepositoryViewTabs [
	<return: #BrTabGroup>

	tabsElement := GtPhlowCompositeView new
		views: self repositoryViewItems;
		asElementDo: [ :aBrTabGroup | aBrTabGroup ].

	^ tabsElement
]

{ #category : #'api - repository view model' }
GtGitRepositoryElement >> onRepositoryViewModelChanged [
	"Is sent when a new repository view model is assigned to the element.
	Note: #onRepositoryViewModelChanged is sent before #subscribeToRepositoryViewModel
	which means that if you perform any operation that triggers an announcement it will be ignored because the receiver
	didn't get a chance to subscribe to any announcement. Override #onPostRepositoryViewModelChanged if you
	wish to perform an operation that requires an announcement, but keep in mind that this is not the most efficient way"

	self updateElement.
]

{ #category : #accessing }
GtGitRepositoryElement >> pagerButtonLabelled: aString spawningElement: aBlockCreatingElement inPager: aPager [

	^ BrButton new
		  aptitude: BrGlamorousButtonWithLabelAptitude;
		  margin: (BlInsets all: 5);
		  label: aString;
		  action: [ 
			  aPager addPage: (BrPagerPageElement new
						   layout: BlLinearLayout vertical alignCenter;
						   weight: 1.0;
						   addChild: aBlockCreatingElement value).
			  aPager scrollToLast ]
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> pullFrom: aButton [

	[ self repositoryViewModel pull ]
		on: IceMergeResolutionRequest
		do: [ :mergeException | 
			BlTaskAction 
				enqueueElement: aButton 
				action: [ self phlow spawnObject: mergeException merge ] ].
	BlTaskAction 
		enqueueElement: aButton 
		action: [ aButton phlow fireToolUpdateWish ]
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> pushFrom: aButton [
	self repositoryViewModel push.
	BlTaskAction 
		enqueueElement: aButton 
		action: [ aButton phlow fireToolUpdateWish ]
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> repository [
	^ self repositoryViewModel repositoryModel repository
]

{ #category : #acce }
GtGitRepositoryElement >> repositoryModel [
	^ self repositoryViewModel repositoryModel 
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> repositoryViewItems [

	| aRepository collector context |
	self repositoryViewModel hasRepository ifFalse: [ ^ #(  ) ].
	aRepository := self repositoryViewModel repositoryModel.

	collector := GtPhlowViewsCollector new
		             fromObject: aRepository;
		             pragmaName: #gtRepositoryView.

	context := GtPhlowContext new.
	context optionAt: #repositoryViewModel put: self repositoryViewModel.

	collector context: context.

	^ collector collect
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> showCommits: aListOfCommits on: aDropdown withAction: aBlock named: aString [

	| aContainer |
	aContainer := BrVerticalPane new
		              vFitContentLimited;
		              hExact: 600;
		              alignCenterRight.

	aContainer addChild: (GtPhlowColumnedListView new
			 title: 'Commits' translated;
			 items: aListOfCommits;
			 send: [:item | self phlow spawnObject: item];
			 column: 'Timestamp'
			 text: [ :aCommit | aCommit timeStamp asStringYMDHM ]
			 width: 120;
			 column: 'Commit' text: #shortId width: 70;
			 column: 'Author' text: #author width: 100;
			 column: 'Description' text: #comment) asElement.
	aContainer addChild: (BrButton new
			 aptitude: BrGlamorousButtonWithIconAptitude;
			 icon: BrGlamorousVectorIcons accept;
			 label: aString;
			 margin: (BlInsets
					  top: 10
					  left: 0
					  bottom: 10
					  right: 10);
			 action: [ :aButton | 
				 aButton fireEvent: BrDropdownHideWish new.
				 aBlock value: aButton ]).
	^ aContainer
]

{ #category : #initialization }
GtGitRepositoryElement >> statusElement [
	^ statusElement
]

{ #category : #initialization }
GtGitRepositoryElement >> subscribeToSignals [

	(updater isNotNil or: [ self repositoryViewModel hasRepository not ]) 
		ifTrue: [ ^ self ].
	updater := BrElementUpdater new.
	updater postponedDuration: 1 seconds.
	updater element: self.
	updater action: [ :e | 
		e updateElement.
		updater resetUpdateRequested ].
	self repositoryViewModel weak
		when: GtRepositoryModified
		send: #handleAnnouncement:
		to: self
]

{ #category : #'private - accessing' }
GtGitRepositoryElement >> tabsElement [
	^ tabsElement
]

{ #category : #'private - accessing' }
GtGitRepositoryElement >> toolbarElement [
	^ toolbarElement
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> updateDefinitionsElement [

	| elem |
	(self hasRepositoryViewModel not or: [ 
		 self repositoryViewModel hasRepository not ]) ifTrue: [ ^ self ].
	elem := GtGitDefinitionsElement new repositoryViewModel:
		        self repositoryViewModel.
	self
		replaceChild: self definitionsElement
		with: elem
		as: #definitions.
	definitionsElement := elem
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> updateElement [
	self updateTabsElement.
	self updateToolbarElement.
	self updateDefinitionsElement.
	self updateTitleElement.
	self subscribeToSignals.
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> updateTabsElement [

	self lazyTabsElement removeChildren.
	self lazyTabsElement addChild: (self newRepositoryViewTabs id: #tabs)
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> updateTitleElement [
	(self hasRepositoryViewModel not or: [ 
		 self repositoryViewModel hasRepository not ]) ifTrue: [ ^ self ].
	self labelElement text: self repositoryViewModel name asString
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> updateToolbarElement [
	| outgoingCommits incomingCommits |
	(self hasRepositoryViewModel not
		or: [ self repositoryViewModel hasRepository not ]) ifTrue: [ ^ self ].

	toolbarElement removeAllItems.
	toolbarElement
		addItem: (labelElement := self createRepositoryLabelElement);
		addItem: self createRemoveRepositoryButton;
		addItem: self createActionsHeaderSeparator;
		addItem: self createInspectRepositoryButton;
		addItem: self createFetchRepositoryButton.

	incomingCommits := self repositoryViewModel incomingCommits.
	outgoingCommits := self repositoryViewModel outgoingCommits.

	(self repositoryViewModel isMissing or: [ self repository remotes isEmpty ])
		ifFalse: [ toolbarElement
				addItem: (incomingCommits isNotEmpty
						ifTrue: [ self createPullRepositoryWithIncomingCommits: incomingCommits ]
						ifFalse: [ self createPullRepositoryWithNoIncommingCommitsButton ]) ].

	(outgoingCommits isNotEmpty and: [ self repository remotes isNotEmpty ])
		ifTrue: [ toolbarElement addItem: (self createPushButtonForCommits: outgoingCommits) ].

	self repositoryViewModel needsRepair
		ifTrue: [ toolbarElement addItem: self createRepairRepositoryButton ]
]
