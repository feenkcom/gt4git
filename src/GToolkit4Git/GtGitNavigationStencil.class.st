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
	<return: #BrTabGroup>
	^ GtPhlowCompositeView new
		views: (GtPhlowViewsCollector new
		fromObject: self;
		pragmaName: #gtGitNavigation;
		collect);
		asElementDo: [ :aTabGroup | 
			aTabGroup 
				background: BrGlamorousColors neutralBackgroundColor;
				matchParent ]
]

{ #category : #accessing }
GtGitNavigationStencil >> createList [

	<return: #BrColumnedList>
	| element |
	^ GtPhlowColumnedListView new
		  updateWhen: IceRepositoryAnnouncement in: [ Iceberg announcer ];
		  items: [ 
			  self navigationModel repositories collect: [ :eachIceRepository | 
					  GtGitRepository new repository: eachIceRepository ] ];
		  send: [ :repo | 
			  self announce: (GtGitRepositorySelected new repository: repo) ];
		  column: 'Repository' translated text: [ :each | each name asRopedText glamorousRegularSmallSize ]
		  width: 200;
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
GtGitNavigationStencil >> createListFor: aView [

	<gtGitNavigation>
	| element |
	^ aView columnedList
		  title: 'Repositories';
		  updateWhen: IceRepositoryAnnouncement in: [ Iceberg announcer ];
		  items: [ 
			  self navigationModel repositories collect: [ :eachIceRepository | 
					  GtGitRepository new repository: eachIceRepository ] ];
		  send: [ :repo | 
			  self announce: (GtGitRepositorySelected new repository: repo) ];
		  column: 'Repository' translated
		  text: [ :each | each name asRopedText glamorousRegularSmallSize ]
		  width: 200;
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
