Class {
	#name : #GtGitStatusWithCount,
	#superclass : #GtGitStatus,
	#instVars : [
		'count'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitStatusWithCount >> changesInflection [

	^ count > 1
		  ifTrue: [ 'changes' ]
		  ifFalse: [ 'change' ]
]

{ #category : #accessing }
GtGitStatusWithCount >> count [
	^ count
]

{ #category : #accessing }
GtGitStatusWithCount >> count: aNumber [
	count := aNumber
]

{ #category : #accessing }
GtGitStatusWithCount >> icon [

	^ BlElement new
		  addChild: self bareIcon asElement;
		  addChild: (BrLabel new
				   aptitude: BrGlamorousLabelAptitude;
				   text: count asString);
		  layout: BlLinearLayout horizontal alignCenterLeft;
		  constraintsDo: [ :c | 
			  c horizontal fitContent.
			  c vertical fitContent ]
]
