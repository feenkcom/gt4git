Class {
	#name : #GtGitNavigationStencil,
	#superclass : #BrStencil,
	#instVars : [
		'navigationModel',
		'viewModel'
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
				   	"otherwise is spawns myself"
				   	aTabGroup
				   		when: GtPhlowObjectToSpawn
				   		do: [ :anEvent | anEvent consumed: true ].
					   aTabGroup
						   background: BlTheme default default navigationBackground;
						   matchParent ])
]

{ #category : #accessing }
GtGitNavigationStencil >> createListFor: aView [
	<gtGitNavigation>
	^ aView columnedList
		title: 'Repositories';
		updateWhen: GtRepositoryListChanged
			in: GtRepositoryRegistryAnnouncer default announcer;
		actionDropdownButtonIcon: BrGlamorousVectorIcons add
			tooltip: 'Add repository'
			content: [ :aDropdown :aTarget | 
				| s |
				s := GtGitAddRepositoryStencil new.
				s dropdown: aDropdown.
				s
					onCreated: [ :repo | 
						self announcer
							announce: (GtGitRepositoryAddedAndSelected new
									repository: (GtGitRepository fromIcebergRepository: repo)) ].
				s ];
		actionButtonIcon: BrGlamorousVectorIcons gitfetch
			tooltip: 'Fetch all repositories'
			action: [ self fetchAll ];
		items: [ self repositories ];
		send: [ :repo | self announce: (GtGitRepositorySelected new repository: repo) ];
		actionStencil: [ :anElement | 
				GtSpotterDropdownButtonStencil new
					valuable: [ self repositories ];
					tooltip: 'Search repositories';
					icon: BrGlamorousVectorIcons search;
					objectActOn: [ :anActOnEvent :anItem | 
						anActOnEvent beActed.
						self announce: (GtGitRepositorySelected new repository: anItem).
						"anElement phlow fireToolUpdateWish" ] ]
			tooltip: 'Search repositories';
		actionUpdateButtonTooltip: 'Refresh repositories';
		rowDataBinder: [ :aRowElement :aRepository | 
			aRepository = navigationModel repository
				ifTrue: [ aRowElement states addState: BlElementSelectedState uniqueInstance ]
				ifFalse: [ aRowElement ] ];
		column: 'Repository' translated
			text: [ :each | self viewModel nameFor: each ];
		column: 'Status' translated
			stencil: [ :each | self viewModel statusElementFor: each ]
			width: 100
]

{ #category : #accessing }
GtGitNavigationStencil >> fetchAll [
	| j notification |
	j := (GtJob
			block: [ :job | 
				| totalCount current |
				job label: 'Fetching repositories...'.
				totalCount := self repositories size.
				job max: totalCount.
				current := 0.
				self repositories
					collect: [ :r | 
						job label: 'Fetching ' , r name.
						current := current + 1.
						job currentValue: current.
						r fetch ] ]) announcer: Announcer new.
	notification := GtNotificationJob new
			summaryClass: GtFetchingNotificationSummary;
			job: j;
			registerNotifications;
			yourself.
	[ j run ] asAsyncPromise
]

{ #category : #accessing }
GtGitNavigationStencil >> initialize [
	super initialize.
	
	viewModel := GtGitNavigationViewModel new
]

{ #category : #accessing }
GtGitNavigationStencil >> navigationModel [
	^ navigationModel
]

{ #category : #accessing }
GtGitNavigationStencil >> navigationModel: aGtGitNavigationModel [
	navigationModel := aGtGitNavigationModel
]

{ #category : #accessing }
GtGitNavigationStencil >> repositories [

	^ (self navigationModel repositories collect: [ :eachIceRepository | 
		  GtGitRepository fromIcebergRepository: eachIceRepository ]) sorted: [:a :b | (a name caseInsensitiveLessOrEqual: b name)]
]

{ #category : #accessing }
GtGitNavigationStencil >> viewModel [
	^ viewModel
]
