Class {
	#name : #GtGitElement,
	#superclass : #BlElement,
	#traits : 'TBrLayoutResizable + TGtPagerPageInstantiator + TGtPhlowToolDetailAdjustable',
	#classTraits : 'TBrLayoutResizable classTrait + TGtPagerPageInstantiator classTrait + TGtPhlowToolDetailAdjustable classTrait',
	#instVars : [
		'titleNotifier',
		'contentElement',
		'sidebarElement',
		'navigationModel',
		'repository'
	],
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #'instance creation' }
GtGitElement class >> onRepository: aRepository [
	^ self new repository: aRepository
]

{ #category : #accessing }
GtGitElement >> asElementDo: aBlock [
	^ aBlock value: self
]

{ #category : #accessing }
GtGitElement >> contentElement [
	^ contentElement
]

{ #category : #accessing }
GtGitElement >> defaultNavigationModel [
	^ GtGitNavigationModel new
]

{ #category : #accessing }
GtGitElement >> initialize [
	super initialize.
	self initializeTitleNotifier.
	self initializeListeners.

	self layout: BlLinearLayout horizontal.
	self matchParent.
	self initializeView.
	self navigationModel: self defaultNavigationModel.
	self phlow 
		accessTool: (GtPhlowToolClassType forClass: self class) 
		viewModel: #navigationModel 
		object: #repository
]

{ #category : #accessing }
GtGitElement >> initializeContentElement [
	| aViewModel |
	aViewModel := GtGitRepositoryViewModel new.
	repository ifNotNil: [
		aViewModel repositoryModel: repository].
	
	contentElement := GtGitRepositoryElement new.
	contentElement navigationModel: navigationModel.
	contentElement repositoryViewModel: aViewModel.
]

{ #category : #accessing }
GtGitElement >> initializeListeners [
]

{ #category : #accessing }
GtGitElement >> initializeNavigationModel [
	self navigationModel: self defaultNavigationModel
]

{ #category : #accessing }
GtGitElement >> initializeSidebarElement [
	sidebarElement := GtPhlowHorizontalSidebarElement new beLeft.
	self addAptitude: (GtPhlowToolDetailAptitude new
		normal: [ :aStyle | aStyle do: [ sidebarElement hide ] ];
		detailed: [ :aStyle | aStyle do: [ sidebarElement show ] ])
]

{ #category : #accessing }
GtGitElement >> initializeTitleNotifier [
	titleNotifier := GtPhlowTitleIconAndLabelNotifier new
		shortLabel: [ self shortTitle ifEmpty: [ 'Git' asRopedText ] ];
		icon: BrGlamorousVectorIcons branching.
	self addEventHandler: titleNotifier.
]

{ #category : #accessing }
GtGitElement >> initializeView [

	self initializeContentElement.
	self initializeSidebarElement.

	self removeChildren.
	self addChild: self sidebarElement as: #sidebar.
	self
		addChild: (self contentElement padding: (BlInsets all: 5))
		as: #content.
]

{ #category : #accessing }
GtGitElement >> navigationModel [
	^ navigationModel
]

{ #category : #accessing }
GtGitElement >> navigationModel: aNavigationModel [
	navigationModel := aNavigationModel.
	self subscribeToNavigationModel.
	self onNavigationModelChanged
]

{ #category : #accessing }
GtGitElement >> onNavigationModelChange: anAnnouncement [
	"Announcements may come from a non-UI process. Let's enqueue the update."

	BlTaskAction
		enqueueElement: self
		action: [ 
			repository := anAnnouncement repository.
			self refreshView.
			self updateTabLabel.
			self fireEvent: (GtPhlowToolObjectChangeWish new object: repository) ]
]

{ #category : #accessing }
GtGitElement >> onNavigationModelChanged [
	self updateSidebarContent
]

{ #category : #accessing }
GtGitElement >> refreshView [

	self initializeContentElement.

	self removeChildren.
	self addChild: self sidebarElement as: #sidebar.
	self
		addChild: (self contentElement padding: (BlInsets all: 5))
		as: #content.
]

{ #category : #accessing }
GtGitElement >> repository [
	^ repository
]

{ #category : #accessing }
GtGitElement >> repository: aRepository [
	repository := aRepository.
	self initializeView.
	self updateSidebarContent.
	repository viewModel announcer weak when: GtRepositoryModified send: #onNavigationModelChange: to: self
]

{ #category : #accessing }
GtGitElement >> shortTitle [

	^ repository ifNil: [ '' ] ifNotNil: [ repository name ]
]

{ #category : #accessing }
GtGitElement >> sidebarElement [
	^ sidebarElement
]

{ #category : #accessing }
GtGitElement >> subscribeToNavigationModel [
	self navigationModel weak
		when: GtGitRepositorySelected
		send: #onNavigationModelChange:
		to: self.

	self navigationModel weak
		when: GtGitRepositoryAddedAndSelected
		send: #onNavigationModelChange:
		to: self
]

{ #category : #accessing }
GtGitElement >> titleNotifier [
	^ titleNotifier
]

{ #category : #accessing }
GtGitElement >> updateSidebarContent [
	self sidebarElement
		contentStencil: (GtGitNavigationStencil new 
			navigationModel: self navigationModel)
]

{ #category : #accessing }
GtGitElement >> updateTabLabel [
	self titleNotifier notify
]
