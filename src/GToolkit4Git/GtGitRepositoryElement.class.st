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
		'statusElement'
	],
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #'instance creation' }
GtGitRepositoryElement class >> on: each [ 
	| aViewModel |
	aViewModel := GtGitRepositoryViewModel new.
	aViewModel repositoryModel: (GtGitRepository new repository: each).
	
	^ self new repositoryViewModel: aViewModel
]

{ #category : #initialization }
GtGitRepositoryElement >> addPackageNamed: aString [ 
	
	self repositoryViewModel addPackage: aString asSymbol
]

{ #category : #initialization }
GtGitRepositoryElement >> defaultLayout [
	^ BlLinearLayout vertical
]

{ #category : #initialization }
GtGitRepositoryElement >> fetchAllRepositoriesFrom: aButton [ 
	self repositoryViewModel fetch.
	aButton phlow fireUpdateWish
]

{ #category : #initialization }
GtGitRepositoryElement >> initialize [
	super initialize.
	self subscribeToSignals.
	self initializeToolbarElement.
	self initializeLazyTabsElement.
	self initializeStatusElement.
	
	self addChild: self toolbarElement as: #toolbar.
	self addChild: self lazyTabsElement as: #lazyTabs.
	self addChild: self statusElement as: #status.
	
	self matchParent.
]

{ #category : #initialization }
GtGitRepositoryElement >> initializeLazyTabsElement [
	lazyTabsElement := BlLazyElement new
		withGlamorousPreview;
		constraintsDo: [ :c | 
			c horizontal matchParent.
			c vertical matchParent ]
]

{ #category : #initialization }
GtGitRepositoryElement >> initializeStatusElement [
	statusElement := BrLabel new 
				                 aptitude: (BrGlamorousLabelAptitude new
						                  labelDo: [ :aLabel | 
							                  aLabel padding: BlInsets empty ]);
				                 beSmallSize;
				                 text: ''
]

{ #category : #initialization }
GtGitRepositoryElement >> initializeToolbarElement [

	toolbarElement := BrToolbar new
		                  aptitude:
			                  (BrGlamorousToolbarAptitude new spacing: 0);
		                  vFitContent;
		                  hMatchParent.          
]

{ #category : #'private - accessing' }
GtGitRepositoryElement >> labelElement [
	^ labelElement
]

{ #category : #'private - accessing' }
GtGitRepositoryElement >> lazyTabsElement [
	^ lazyTabsElement
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

{ #category : #'private - updating' }
GtGitRepositoryElement >> pullFrom: aButton [
	self repositoryViewModel pull.
	aButton phlow fireUpdateWish
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> pushFrom: aButton [
	self repositoryViewModel push.
	aButton phlow fireUpdateWish
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

{ #category : #initialization }
GtGitRepositoryElement >> statusElement [
	^ statusElement
]

{ #category : #initialization }
GtGitRepositoryElement >> subscribeToSignals [
	Iceberg announcer weak when: IceRepositoryAnnouncement send: #updateElement to: self
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
GtGitRepositoryElement >> updateElement [
	self updateTabsElement.
	self updateToolbarElement.
	self updateTitleElement.
	self updateStatusElement.
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> updateStatusElement [
	(self hasRepositoryViewModel not or: [ 
		 self repositoryViewModel hasRepository not ]) ifTrue: [ ^ self ].
	self statusElement text: self repositoryViewModel status
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> updateTabsElement [
	self lazyTabsElement element: nil.
	self lazyTabsElement elementBuilder: [ self newRepositoryViewTabs id: #tabs ]
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> updateTitleElement [
	(self hasRepositoryViewModel not or: [ 
		 self repositoryViewModel hasRepository not ]) ifTrue: [ ^ self ].
	self labelElement text: self repositoryViewModel name
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> updateToolbarElement [

	| look aDropdown |
	(self hasRepositoryViewModel not or: [ 
		 self repositoryViewModel hasRepository not ]) ifTrue: [ ^ self ].

	toolbarElement removeAllItems.
	toolbarElement
		addItem: (labelElement := BrLabel new
				                 aptitude: (BrGlamorousLabelAptitude new
						                  bold;
						                  labelDo: [ :aLabel | 
							                  aLabel padding: BlInsets empty ]);
				                 beHugeSize;
				                 text: '');
		addItem: (BrFrame new
				 vFitContent;
				 hMatchParent);
		addItem: (BrButton new
				 aptitude: BrGlamorousButtonWithIconAptitude;
				 icon: BrGlamorousVectorIcons inspect;
				 label: 'Inspect';
				 action: [ :aButton | 
					 aButton phlow spawnObject: self repositoryViewModel repositoryModel ]);
		addItem: (BrButton new
				 aptitude: BrGlamorousButtonWithIconAptitude;
				 icon: BrGlamorousVectorIcons refresh;
				 label: 'Fetch';
				 action: [ :aButton | 
					 self fetchAllRepositoriesFrom: aButton.
					 aButton phlow fireUpdateWish ]);
		addItem: (BrButton new
				 aptitude: BrGlamorousButtonWithIconAptitude;
				 icon: BrGlamorousVectorIcons down;
				 label: 'Pull';
				 action: [ :aButton | 
					 self pullFrom: aButton.
					 aButton phlow fireUpdateWish ]);
		addItem: (BrButton new
				 aptitude: BrGlamorousButtonWithIconAptitude;
				 icon: BrGlamorousVectorIcons up;
				 label: 'Push';
				 action: [ :aButton | 
					 self pushFrom: aButton.
					 aButton phlow fireUpdateWish ]).

	self repositoryViewModel needsRepair ifTrue: [ 
		toolbarElement addItem: (aDropdown := BrButton new
				 aptitude: BrGlamorousButtonWithLabelAptitude
					 + (BrGlamorousWithDropdownAptitude
							  handle: [ 
								  BrButton new
									  aptitude:
										  BrGlamorousButtonWithLabelAptitude
										  - BrGlamorousButtonExteriorAptitude;
									  label: 'Repair' ]
							  content: [
							  self repositoryViewModel repairStencilFor: aDropdown ]);
				 label: 'Repair') ]
]
