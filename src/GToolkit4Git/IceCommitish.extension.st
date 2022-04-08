Extension { #name : #IceCommitish }

{ #category : #'*GToolkit4Git' }
IceCommitish >> commitStream [
	
	^ self newCommitWalk commitStream
]

{ #category : #'*GToolkit4Git' }
IceCommitish >> gtDiffTo: aCommitish [

	^ GtGitIceDiff from: self to: aCommitish
]

{ #category : #'*GToolkit4Git' }
IceCommitish >> gtLepiterAwareCheckoutWithWorkingCopy: aLepiterWorkingCopy [
	
	self checkout: (GtGitIceCheckoutAlreadyLoadedContent new
		lepiterWorkingCopy: aLepiterWorkingCopy;
		committish: self;
		yourself)
]

{ #category : #'*GToolkit4Git' }
IceCommitish >> treeFor: aRepository [
	^ (aRepository revparse: self gitRef) tree
]
