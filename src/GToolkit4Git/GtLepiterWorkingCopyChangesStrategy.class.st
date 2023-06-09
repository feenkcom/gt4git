Class {
	#name : #GtLepiterWorkingCopyChangesStrategy,
	#superclass : #Object,
	#instVars : [
		'workingCopy'
	],
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #'API - changes' }
GtLepiterWorkingCopyChangesStrategy >> changesTo: aCommitish [
	self subclassResponsibility
]

{ #category : #accessing }
GtLepiterWorkingCopyChangesStrategy >> workingCopy [

	^ workingCopy
]

{ #category : #accessing }
GtLepiterWorkingCopyChangesStrategy >> workingCopy: anObject [

	workingCopy := anObject
]
