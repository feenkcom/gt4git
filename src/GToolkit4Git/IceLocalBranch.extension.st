Extension { #name : #IceLocalBranch }

{ #category : #'*GToolkit4Git' }
IceLocalBranch >> gtPullFrom: aRemote inWorkingCopy: aLepiterWorkingCopy [
	"A copy of the #pullFrom: method to support a Lepiter-aware pull."
	| remoteBranch |
	aRemote fetchBranch: self.
	remoteBranch := aRemote
		remoteBranchNamed: self name
		ifAbsent: [ ^ self ].
	aLepiterWorkingCopy mergeCommit: remoteBranch commit.
]

{ #category : #'*GToolkit4Git' }
IceLocalBranch >> gtPullInWorkingCopy: aLepiterWorkingCopy [
	"A copy of the #pull method to support a Lepiter-aware pull."
	self 
		gtPullFrom: self upstream remote 
		inWorkingCopy: aLepiterWorkingCopy
]
