Class {
	#name : #GtGitCheckoutNewBranch,
	#superclass : #GtGitRepairAction,
	#category : #'GToolkit4Git-Inspector Integration - Actions'
}

{ #category : #accessing }
GtGitCheckoutNewBranch class >> iceTipClass [
	^ IceTipRepairCheckoutNewBranch
]

{ #category : #accessing }
GtGitCheckoutNewBranch >> repairStencil [
	| container |
	container := BrHorizontalPane new
			fitContent;
			addChild: (GtGitNewBranchForm new
						repository: repository;
						dropdown: dropdown) asElement
				as: #branchName.
	^ container
]
