Class {
	#name : #GtGitStatusWithCount,
	#superclass : #GtGitStatus,
	#instVars : [
		'count'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitStatusWithCount >> count [
	^ count
]

{ #category : #accessing }
GtGitStatusWithCount >> count: aNumber [
	count := aNumber
]

{ #category : #accessing }
GtGitStatusWithCount >> iconWithCount: anIcon [
	BrButton new
		aptitude: BrGlamorousButtonLabelAndIconAptitude;
		label: count;
		disable;
		icon: anIcon
]
