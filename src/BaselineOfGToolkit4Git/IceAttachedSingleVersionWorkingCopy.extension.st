Extension { #name : #IceAttachedSingleVersionWorkingCopy }

{ #category : #'*BaselineOfGToolkit4Git' }
IceAttachedSingleVersionWorkingCopy >> gtMergeCommit: aMergeCommit forRepository: aGitRepository [
	^ GtGitIceMerge new
		repository: aGitRepository;
		mergeCommit: aMergeCommit;
		execute.
]
