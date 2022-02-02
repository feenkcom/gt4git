Class {
	#name : #GtGitNavigationViewModel,
	#superclass : #Object,
	#instVars : [
		'statusElements',
		'names'
	],
	#category : #'GToolkit4Git-UI - View Model'
}

{ #category : #accessing }
GtGitNavigationViewModel >> initialize [
	statusElements := Dictionary new.
	names := Dictionary new
]

{ #category : #accessing }
GtGitNavigationViewModel >> nameFor: aRepository [

	^ names
		  at: aRepository
		  ifAbsentPut: [ 
		  aRepository name asRopedText glamorousRegularSmallSize ]
]

{ #category : #accessing }
GtGitNavigationViewModel >> statusElementFor: aRepository [

	^ statusElements
		  at: aRepository
		  ifAbsentPut: [ GtGitStatusElement new repository: aRepository ]
]
