Class {
	#name : #GtGitRepositoryElement,
	#superclass : #BlElement,
	#traits : 'TGtGitWithRepositoryViewModel + TBrLayoutResizable',
	#classTraits : 'TGtGitWithRepositoryViewModel classTrait + TBrLayoutResizable classTrait',
	#instVars : [
		'tabsElement',
		'toolbarElement',
		'labelElement',
		'lazyTabsElement'
	],
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #initialization }
GtGitRepositoryElement >> defaultLayout [
	^ BlLinearLayout vertical
]

{ #category : #initialization }
GtGitRepositoryElement >> initialize [
	super initialize.
	self initializeToolbarElement.
	self initializeLazyTabsElement.
	
	self addChild: self toolbarElement as: #toolbar.
	self addChild: self lazyTabsElement as: #lazyTabs.
	
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
GtGitRepositoryElement >> initializeToolbarElement [
	toolbarElement := BrToolbar new
		look: (BrGlamorousToolbarLook new spacing: 0);
		vFitContent;
		hMatchParent.
	
	toolbarElement
		addItem: (labelElement := BrLabel new
			look: (BrGlamorousLabelLook new 
				bold; 
				labelDo: [ :aLabel | aLabel padding: BlInsets empty ]);
			beHugeSize;
			text: '');
		addItem: (BrFrame new
			vFitContent;
			hMatchParent);
		addItem: (BrButton new
			look: BrGlamorousButtonWithIconLook;
			icon: BrGlamorousVectorIcons refresh;
			label: 'Fetch';
			action: [ :aButton | self fetchAllRepositoriesFrom: aButton ]);
		addItem: (BrButton new
			look: BrGlamorousButtonWithIconLook;
			icon: BrGlamorousVectorIcons add;
			label: 'Something')
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
GtGitRepositoryElement >> repositoryViewItems [
	| aRepository collector context |
	
	aRepository := self repositoryViewModel repositoryModel.

	collector := GtPhlowViewsCollector new
		fromObject: aRepository;
		pragmaName: #gtRepositoryView.

	context := GtPhlowContext new.
	context optionAt: #repositoryViewModel put: self repositoryViewModel.

	collector context: context.

	^ collector collect
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
	self updateTitleElement.
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> updateTabsElement [
	self lazyTabsElement elementBuilder: [ self newRepositoryViewTabs id: #tabs ]
]

{ #category : #'private - updating' }
GtGitRepositoryElement >> updateTitleElement [
	self labelElement text: self repositoryViewModel name
]
