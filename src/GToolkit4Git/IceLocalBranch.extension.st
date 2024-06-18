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

{ #category : #'*GToolkit4Git' }
IceLocalBranch >> gtSwitchActionFor: anAction [
	<gtAction>
	^ anAction button
		label: 'Switch';
		tooltip: 'Switch to this branch (do not load)';
		priority: 30;
		action: [ self switch ]
]

{ #category : #'*GToolkit4Git' }
IceLocalBranch >> isDirty [
	^ self isLoaded and: [ self repository workingCopy isModified ]
]

{ #category : #'*GToolkit4Git' }
IceLocalBranch >> isLoaded [
	^self repository workingCopy referenceCommit = self commit
]
