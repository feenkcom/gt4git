Class {
	#name : #GtGitRepositoryRepairStencil,
	#superclass : #BrStencil,
	#instVars : [
		'container',
		'pager',
		'repository',
		'dropdown'
	],
	#category : #'GToolkit4Git-Inspector Integration'
}

{ #category : #accessing }
GtGitRepositoryRepairStencil >> create [
	^ self createMainContainer 
]

{ #category : #accessing }
GtGitRepositoryRepairStencil >> createMainContainer [

	container ifNil: [ 
		container := BrVerticalPane new
			             addAptitude: BrGlamorousWithHorizontalResizerAptitude;
			             addAptitude: BrGlamorousWithVerticalResizerAptitude;
			             fitContent;
			             padding: (BlInsets all: 5);
			             addChildren: self createRepairButtonsList ].

	^ container
]

{ #category : #accessing }
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
			  hFitContent.
		  local aptitude: BrGlamorousButtonWithLabelAptitude.
		  local action: [ self openAction: a ].
		  local ]
]

{ #category : #accessing }
GtGitRepositoryRepairStencil >> dropdown: aDropdown [ 
	dropdown := aDropdown
]

{ #category : #accessing }
GtGitRepositoryRepairStencil >> openAction: aGtGitRepairAction [

	container removeChildren.
	container addChild: aGtGitRepairAction repairStencil
]

{ #category : #accessing }
GtGitRepositoryRepairStencil >> repository: aRepository [
	repository := aRepository
]
