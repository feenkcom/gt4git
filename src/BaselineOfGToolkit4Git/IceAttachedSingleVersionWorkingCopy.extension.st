Extension { #name : #IceAttachedSingleVersionWorkingCopy }

{ #category : #'*BaselineOfGToolkit4Git' }
IceAttachedSingleVersionWorkingCopy >> gtMergeCommit: aMergeCommit forWorkingCopy: aLepiterWorkingCopy [
	^ GtGitIceMerge new
		lepiterWorkingCopy: aLepiterWorkingCopy;
		repository: aLepiterWorkingCopy icebergRepository;
		mergeCommit: aMergeCommit;
		execute
]
