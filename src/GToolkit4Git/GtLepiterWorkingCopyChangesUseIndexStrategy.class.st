Class {
	#name : #GtLepiterWorkingCopyChangesUseIndexStrategy,
	#superclass : #GtLepiterWorkingCopyChangesStrategy,
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #'API - changes' }
GtLepiterWorkingCopyChangesUseIndexStrategy >> changesTo: aCommitish [
	^ self workingCopy changesToHeadUsingIndex
]
