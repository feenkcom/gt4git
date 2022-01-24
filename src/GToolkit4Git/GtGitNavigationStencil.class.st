Class {
	#name : #GtGitNavigationStencil,
	#superclass : #BrStencil,
	#instVars : [
		'navigationModel'
	],
	#category : #'GToolkit4Git-UI'
}

{ #category : #accessing }
GtGitNavigationStencil >> announce: anObject [ 
	self announcer announce: anObject
]

{ #category : #announcer }
GtGitNavigationStencil >> announcer [
	^ navigationModel announcer
]

{ #category : #accessing }
GtGitNavigationStencil >> create [

	^ GtGitNavigationElement new
		  navigationModel: self navigationModel;
		  addChild: (GtPhlowCompositeView new
				   views: (GtPhlowViewsCollector new
						    fromObject: self;
						    pragmaName: #gtGitNavigation;
						    collect);
				   asElementDo: [ :aTabGroup | 
					   aTabGroup
						   background: BrGlamorousColors neutralBackgroundColor;
						   matchParent ])
]

{ #category : #accessing }
GtGitNavigationStencil >> createListFor: aView [

	<gtGitNavigation>
	| items element |
	items := self navigationModel repositories collect: [ 
		         :eachIceRepository | 
		         GtGitRepository new repository: eachIceRepository ].
	^ aView columnedList
		  title: 'Repositories';
		  updateWhen: IceRepositoryAnnouncement in: [ Iceberg announcer ];
		  actionDropdownButtonIcon: BrGlamorousVectorIcons add
		  tooltip: 'Add Repository'
		  content: [ :aDropdown :aTarget | 
			  | s |
			  s := GtGitAddRepositoryStencil new.
			  s dropdown: aDropdown.
			  s repoGroup: self.
			  s ];
		  actionButtonIcon: BrGlamorousVectorIcons refresh
		  tooltip: 'Fetch all'
		  action: [ 
			  [ self navigationModel repositories collect: [ :r | r fetch ] ]
				  fork ];
		  items: [ items ];
		  send: [ :repo | 
			  self announce: (GtGitRepositorySelected new repository: repo) ];
		  actionStencil: [ :anElement | 
			  GtSpotterDropdownButtonStencil new
				  object: items;
				  tooltip: 'Search Repositories';
				  icon: BrGlamorousVectorIcons search;
				  actOn: [ :anActOnEvent :anItem | 
					  anActOnEvent beActed.
					  self announce: (GtGitRepositorySelected new repository: anItem).
					  anElement phlow fireUpdateWish ] ]
		  tooltip: 'Search Repositories';
		  column: 'Repository' translated
		  text: [ :each | each name asRopedText glamorousRegularSmallSize ];
		  column: 'Status' translated stencil: [ :each | 
			  element := BlElement new
				             layout: BlLinearLayout horizontal;
				             constraintsDo: [ :c | 
					             c vertical fitContent.
					             c horizontal fitContent ].
			  each statusModel do: [ :status | 
				  element addChild: status asElement ].
			  element ]
		  width: 100
]

{ #category : #accessing }
GtGitNavigationStencil >> navigationModel [
	^ navigationModel
]

{ #category : #accessing }
GtGitNavigationStencil >> navigationModel: aGtGitNavigationModel [
	navigationModel := aGtGitNavigationModel
]
