Class {
	#name : #GtLepiterWorkingCopyChangesCheckAllStrategy,
	#superclass : #GtLepiterWorkingCopyChangesStrategy,
	#category : #'GToolkit4Git-Lepiter'
}

{ #category : #'API - changes' }
GtLepiterWorkingCopyChangesCheckAllStrategy >> changesTo: aCommitish [
	^ self workingCopy databases 
		collect: [ :aDatabase |
			GtLepiterLocalDatabaseChange new
				database: aDatabase ]
]
