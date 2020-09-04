Class {
	#name : #GtGitRepairAction,
	#superclass : #GtGitAction,
	#instVars : [
		'repository'
	],
	#category : #'GToolkit4Git-Actions'
}

{ #category : #accessing }
GtGitRepairAction class >> iceTipClass [
	^ self subclassResponsibility
]

{ #category : #accessing }
GtGitRepairAction >> repository: aRepository [
	repository := aRepository
]
