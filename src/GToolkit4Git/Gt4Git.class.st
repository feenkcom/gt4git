Class {
	#name : #Gt4Git,
	#superclass : #Object,
	#instVars : [
		'repos'
	],
	#category : #'GToolkit4Git-Inspector Integration'
}

{ #category : #accessing }
Gt4Git >> buildButtonsContainer: aButtonsContainer listWidget: anElement [
	| label repositoriesA repositoriesU repositoriesI repositoriesO repositoriesD repositoriesH |
	aButtonsContainer removeChildren.
	
	
	repositoriesA := self cachedRepositories
		collect: [ :r | GtGitRepository2 fromIcebergRepository: r ].
	aButtonsContainer
		addChild:
			(BrButton new
				aptitude: BrGlamorousButtonWithLabelAptitude;
				beSmallSize;
				label: 'All';
				action: [ anElement children second items: repositoriesA ]).
	repositoriesU := (repositoriesA
		select: [ :r | 
			[ r isModified ]
				on: Error
				do: [ false ] ]).
	label := repositoriesU size asString , ' Uncommited'.
	aButtonsContainer
		addChild:
			(BrButton new
				aptitude: BrGlamorousButtonWithLabelAptitude;
				beSmallSize;
				label: label;
				action: [ anElement children second items: repositoriesU ]).
	repositoriesI := (repositoriesA
		select: [ :r | 
			[ r incomingCommits size > 0 ]
				on: Error
				do: [ false ] ]).
	label := repositoriesI size asString , ' Incoming'.
	aButtonsContainer
		addChild:
			(BrButton new
				aptitude: BrGlamorousButtonWithLabelAptitude;
				beSmallSize;
				label: label;
				action: [ anElement children second items: repositoriesI ]).
	repositoriesO := (repositoriesA
		select: [ :r | 
			[ r outgoingCommits size > 0 ]
				on: Error
				do: [ false ] ]).
	label := repositoriesO size asString , ' Outgoing'.
	aButtonsContainer
		addChild:
			(BrButton new
				aptitude: BrGlamorousButtonWithLabelAptitude;
				beSmallSize;
				label: label;
				action: [ anElement children second items: repositoriesO ]).
				
	repositoriesD := (repositoriesA
		select: [ :r | r isMissing not and: [ r workingCopy isDetached ] ]).
	label := repositoriesD size asString , ' Detached Working Copy'.
	aButtonsContainer
		addChild:
			(BrButton new
				aptitude: BrGlamorousButtonWithLabelAptitude;
				beSmallSize;
				label: label;
				action: [ anElement children second items: repositoriesD ]).
				
	repositoriesH := (repositoriesA
		select: [ :r | 
			[ r head isDetached ]
				on: Error
				do: [ false ] ]).
	label := repositoriesH size asString , ' Detached HEAD'.
	aButtonsContainer
		addChild:
			(BrButton new
				aptitude: BrGlamorousButtonWithLabelAptitude;
				beSmallSize;
				label: label;
				action: [ anElement children second items: repositoriesH ])
]

{ #category : #accessing }
Gt4Git >> buildListViewFor: aView [
	| result |
	result := aView columnedList
		title: 'Repositories' translated;
		priority: 50;
		send: [ :each | each ];
		updateWhen: IceRepositoryAnnouncement
			in: [ Iceberg announcer ];
		items: [ self repositories
			collect: [ :eachIceRepository | (GtGitRepository2 fromIcebergRepository: eachIceRepository) ] ];
		column: 'Repository' translated
			text: [ :each | 
			| description |
			description := each name asRopedText.
			each isModified
				ifTrue: [ description := ('*' , description asString) asRopedText foreground: (Color r: 0 g: 0.5 b: 0) ].
			description ]
			width: 200;
		column: 'Branch' translated
			text: [ :each | each headDescription ]
			width: 200;
		column: 'Status' translated
			text: [ :each | each status ]
			width: 200.
	^ result
]

{ #category : #accessing }
Gt4Git >> cachedRepositories [
	repos ifNil: [repos := self repositories].
	^ repos
]

{ #category : #accessing }
Gt4Git >> gtRepositoriesFor: aView [
	<gtView>
	^ aView explicit
		title: 'Repositories';
		priority: 11;
		actionButtonLabel: 'Fetch All' 
			action: [[self repositories collect: [:r | r fetch]] fork];
		actionDropdownButtonLabel: '+'
			tooltip: 'Add Repository'
			content: [ :aDropdown :aTarget | 
			|s|
			s := GtGitAddRepositoryStencil new.
			s dropdown: aDropdown.
			s repoGroup: self.
			s ];
		stencil: [ | aContainer aButtonsContainer aListView |
			aContainer := BlElement new
				layout: BlLinearLayout vertical;
				constraintsDo: [ :c | 
					c padding: (BlInsets all: 3).
					c horizontal matchParent.
					c vertical matchParent ].
			aButtonsContainer := BlElement new
				layout: (BlLinearLayout horizontal cellSpacing: 3);
				constraintsDo: [ :c | 
					c padding: (BlInsets all: 3).
					c horizontal fitContent.
					c vertical fitContent.
					c linear horizontal alignCenter ].
			aContainer addChild: aButtonsContainer.
			aListView := self buildListViewFor: aView.
			aListView
				asElementDo: [ :anElement |
					aContainer addChild: anElement.
					self buildButtonsContainer: aButtonsContainer
						listWidget: anElement.
					Iceberg announcer unsubscribe: self.
					Iceberg announcer weak 
						when: IceRepositoryAnnouncement 
						send: #update
						to: (Gt4GitUpdateRepositoryButtonsAction new
							git: self;
							buttonsContainer: aButtonsContainer;
							listElement: anElement) ].
			aContainer ]
]

{ #category : #'gt-extensions' }
Gt4Git >> gtUpdateFor: anAction [
	<gtAction>
	^ anAction button
		icon: BrGlamorousVectorIcons refresh;
		tooltip: 'Refresh all views';
		action: [ :aButton | aButton phlow fireUpdateWish ]
]

{ #category : #accessing }
Gt4Git >> repositories [
	repos := IceRepository registry copyFrom: 1 to: IceRepository registry size.
	repos := repos sort: [:a :b | 
	|aM bM result|
	aM := (IceTipRepositoryModel on: a).
	bM := (IceTipRepositoryModel on: b).
	(aM isModified and:[ bM isModified not]) ifTrue: [result := true]. 
	(bM isModified and:[ aM isModified not]) ifTrue: [result := false].
	
	(result ifNil: [result := a name asLowercase < b name asLowercase]).
	result].
	^ repos
]
