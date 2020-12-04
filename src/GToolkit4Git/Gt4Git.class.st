Class {
	#name : #Gt4Git,
	#superclass : #Object,
	#category : #GToolkit4Git
}

{ #category : #accessing }
Gt4Git >> buildButtonsContainer: aButtonsContainer listWidget: anElement [
	|label repositoriesA repositoriesU repositoriesI repositoriesO repositoriesD repositoriesH|
	aButtonsContainer removeChildren.
	repositoriesA := (self repositories) collect: [:r | GtGitRepository fromIcebergRepository: r].
	aButtonsContainer addChild: (BrButton new 
		look: BrGlamorousButtonWithLabelLook; beSmall; 
		label: 'All';
		action: [ anElement children second items: repositoriesA ]).
	
	repositoriesU := (self repositories select: 
				[:r | [r isModified] on: Error do:[false] ]) collect: [:r | GtGitRepository fromIcebergRepository: r].				
				
	label :=  repositoriesU size asString, ' Uncommited'.
	aButtonsContainer addChild: (BrButton new 
		look: BrGlamorousButtonWithLabelLook; beSmall; 
		label: label;
		action: [ anElement children second items: 
			repositoriesU ]).
	
	repositoriesI := (self repositories select: 
				[:r | [(IceTipRepositoryModel on: r) incomingCommits size > 0] 
					on: Error do:[false] ]) collect: [:r | GtGitRepository fromIcebergRepository: r]. 
	label := repositoriesI size asString, ' Incoming'.
	aButtonsContainer addChild: (BrButton new 
		look: BrGlamorousButtonWithLabelLook; beSmall; 
		label: label;
		action: [ anElement children second items: repositoriesI]).
	
	repositoriesO := (self repositories select: 
				[:r | [(IceTipRepositoryModel on: r) outgoingCommits size > 0] 
					on: Error do:[false] ]) collect: [:r | GtGitRepository fromIcebergRepository: r]. 
	label := repositoriesO size asString, ' Outgoing'.
	aButtonsContainer addChild: (BrButton new 
		look: BrGlamorousButtonWithLabelLook; beSmall; 
		label: label;
		action: [ anElement children second items: repositoriesO]).
	
	
	repositoriesD := (self repositories select: 
				[:r | r isMissing not and: [r workingCopy isDetached]]) collect: [:r | GtGitRepository fromIcebergRepository: r].
	label := repositoriesD size asString, ' Detached Working Copy'.
	aButtonsContainer addChild: (BrButton new 
		look: BrGlamorousButtonWithLabelLook; beSmall; 
		label: label;
		action: [ anElement children second items: repositoriesD ]).
	
	repositoriesH := (self repositories select: 
				[:r | [r head isDetached] 
					on: Error do:[false]]) collect: [:r | GtGitRepository fromIcebergRepository: r].
	label := repositoriesH size asString, ' Detached HEAD'.
	
	aButtonsContainer addChild: (BrButton new 
		look: BrGlamorousButtonWithLabelLook; beSmall; 
		label: label;
		action: [ anElement children second items: repositoriesH]).
	
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
Gt4Git >> gtRepositoriesFor: aView [
	<gtView>
	^ aView explicit
		title: 'Repositories';
		priority: 11;
		updateWhen: IceRepositoryAnnouncement in: [Iceberg announcer];
		addAutoUpdate: GtPhlowUpdateViewOnAddedToScene;
		actionButtonLabel: 'Fetch All' 
			action: [self repositories collect: [:r | r fetch]];
		actionDropdownButtonLabel: '+'
			tooltip: 'Add Repository'
			content: [ :aDropdown :aTarget | 
			|s|
			s := GtGitAddRepositoryStencil new.
			s dropdown: aDropdown.
			s repoGroup: self.
			s			
			];
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
						listWidget: anElement ].
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
	|repos|
	repos := IceRepository registry copyFrom: 1 to: IceRepository registry size.
	repos := repos sort: [:a :b | 
	|aM bM result|
	aM := (IceTipRepositoryModel on: a).
	bM := (IceTipRepositoryModel on: b).
	(aM isModified and:[ bM isModified not]) ifTrue: [result := true]. 
	(bM isModified and:[ aM isModified not]) ifTrue: [result := false].
	
	(result ifNil: [result := a name translateToLowercase < b name translateToLowercase]).
	result].
	^ repos
]
