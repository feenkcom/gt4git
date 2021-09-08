Class {
	#name : 'GtGitRepositoryRepairStencil',
	#superclass : 'BrStencil',
	#instVars : [
		'container',
		'pager',
		'repository',
		'dropdown'
	],
	#category : 'GToolkit4Git-Inspector Integration'
}

{ #category : 'accessing' }
GtGitRepositoryRepairStencil >> create [
	^ self createMainContainer 
]

{ #category : 'accessing' }
GtGitRepositoryRepairStencil >> createMainContainer [
	container ifNil: [
		pager := BrPager new.
		pager matchParent.
		container := BlElement new.
		container size: 480@400.
		container addChild: pager.
		pager addPage: self initialPage.

		container addChild: (BrResizer new
			target: container ;
			beBottom;
			aptitude: (BrGlamorousResizerAptitude new);
			constraintsDo: [ :c | 
				c ignoreByLayout.
				c ignored horizontal weight: 0.2 ]).
		container addChild: (BrResizer new
			target:container;
			beLeft;
			aptitude: BrGlamorousResizerAptitude;
			constraintsDo: [ :c | 
				c ignoreByLayout.
				c ignored vertical weight: 0.2 ]).
		container addChild: (BrResizer new
			target: container ;
			beRight;
			aptitude: BrGlamorousResizerAptitude;
			constraintsDo: [ :c | 
				c ignoreByLayout.
				c ignored vertical weight: 0.2 ]) ].

	^ container
]

{ #category : 'accessing' }
GtGitRepositoryRepairStencil >> createRepairButtonsList [

	| local |
	^ ((GtGitRepairAction subclasses select: [ :sc | 
		    sc iceTipClass isAvailableFor: repository ]) collect: [ :sc | 
		   sc new
			   repository: repository;
			   dropdown: dropdown ]) collect: [ :a | 
		  local := BrButton new.
		  local
			  label: a class iceTipClass title;
			  beHugeSize;
			  hFitContent.
		  local aptitude: BrGlamorousButtonWithLabelAptitude.
		  local action: [ self openPageForAction: a ].
		  local ]
]

{ #category : 'accessing' }
GtGitRepositoryRepairStencil >> dropdown: aDropdown [ 
	dropdown := aDropdown
]

{ #category : 'accessing' }
GtGitRepositoryRepairStencil >> initialPage [
	|page|
	page := BrPagerPageElement new.
	page weight: 1.0;
		layout: BlLinearLayout vertical alignCenter.
	page addChildren: self createRepairButtonsList.
	^ page
		
]

{ #category : 'accessing' }
GtGitRepositoryRepairStencil >> openPageForAction: aGtGitRepairAction [
	pager addPage: (BrPagerPageElement new
					layout: BlLinearLayout vertical alignCenter;
					weight: 1.0;
					addChild: aGtGitRepairAction repairStencil).
				pager scrollToLast
]

{ #category : 'accessing' }
GtGitRepositoryRepairStencil >> repository: aRepository [
	repository := aRepository
]
