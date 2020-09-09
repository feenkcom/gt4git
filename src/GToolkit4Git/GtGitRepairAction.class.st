Class {
	#name : #GtGitRepairAction,
	#superclass : #GtGitAction,
	#instVars : [
		'repository',
		'dropdown'
	],
	#category : #'GToolkit4Git-Actions'
}

{ #category : #accessing }
GtGitRepairAction class >> iceTipClass [
	^ self subclassResponsibility
]

{ #category : #accessing }
GtGitRepairAction >> dropdown: aDropdown [
	dropdown := aDropdown
]

{ #category : #accessing }
GtGitRepairAction >> repository: aRepository [
	repository := aRepository
]
