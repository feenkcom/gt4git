Class {
	#name : #GtGitRepositoryGroup,
	#superclass : #Object,
	#instVars : [
		'repos'
	],
	#category : #GToolkit4Git
}

{ #category : #accessing }
GtGitRepositoryGroup >> buildButtonsContainer: aButtonsContainer listWidget: anElement [
	|label repositoriesU repositoriesI repositoriesO repositoriesD repositoriesH|
	aButtonsContainer removeChildren.
	aButtonsContainer addChild: (BrButton new 
		look: BrGlamorousButtonWithLabelLook; beSmall; 
		label: 'All';
		action: [ anElement children second items: (self repositories) ]).
	repositoriesU := (self repositories select: 
				[:r | [r isModified] on: Error do:[false] ]).
	label :=  repositoriesU size asString, ' Uncommited'.
	aButtonsContainer addChild: (BrButton new 
		look: BrGlamorousButtonWithLabelLook; beSmall; 
		label: label;
		action: [ anElement children second items: 
			repositoriesU ]).
	
	repositoriesI := (self repositories select: 
				[:r | [(IceTipRepositoryModel on: r) incomingCommits size > 0] 
					on: Error do:[false] ]). 
	label := repositoriesI size asString, ' Incoming'.
	aButtonsContainer addChild: (BrButton new 
		look: BrGlamorousButtonWithLabelLook; beSmall; 
		label: label;
		action: [ anElement children second items: repositoriesI]).
	
	repositoriesO := (self repositories select: 
				[:r | [(IceTipRepositoryModel on: r) outgoingCommits size > 0] 
					on: Error do:[false] ]). 
	label := repositoriesO size asString, ' Outgoing'.
	aButtonsContainer addChild: (BrButton new 
		look: BrGlamorousButtonWithLabelLook; beSmall; 
		label: label;
		action: [ anElement children second items: repositoriesO]).
	
	
	repositoriesD := (self repositories select: 
				[:r | r workingCopy isDetached]).
	label := repositoriesD size asString, ' Detached Working Copy'.
	aButtonsContainer addChild: (BrButton new 
		look: BrGlamorousButtonWithLabelLook; beSmall; 
		label: label;
		action: [ anElement children second items: repositoriesD ]).
	
	repositoriesH := (self repositories select: 
				[:r | [r head isDetached] 
					on: Error do:[false]]).
	label := repositoriesH size asString, ' Detached HEAD'.
	
	aButtonsContainer addChild: (BrButton new 
		look: BrGlamorousButtonWithLabelLook; beSmall; 
		label: label;
		action: [ anElement children second items: repositoriesH]).
	
]

{ #category : #accessing }
GtGitRepositoryGroup >> buildListViewFor: aView [
	| result |
	result := aView columnedList
		title: 'Repositories' translated;
		priority: 50;
		send: [ :each | each repository ];
		updateWhen: IceRepositoryAnnouncement
			if: [ :event | self repositories includes: event repository ]
			in: [ Iceberg announcer ];
		items: [ self repositories
			collect: [ :eachIceRepository | (GtGitRepository fromIcebergRepository: eachIceRepository) load ] ];
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
GtGitRepositoryGroup >> gtRepositoriesFor: aView [
	<gtView>
	^ aView explicit
		title: 'Repositories';
		priority: 11;
		updateWhen: IceRepositoryAnnouncement if: [:event | self repositories includes: event repository ] in: [Iceberg announcer];
		actionButtonLabel: 'Fetch All' action: [self repositories collect: [:r | r fetch]];
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
					self
						buildButtonsContainer: aButtonsContainer
						listWidget: anElement ].
			aContainer ]
]

{ #category : #accessing }
GtGitRepositoryGroup >> repositories [
	^ repos
]

{ #category : #accessing }
GtGitRepositoryGroup >> repositories: aListOfRepositories [
	repos := aListOfRepositories copyFrom: 1 to: aListOfRepositories size.
]
