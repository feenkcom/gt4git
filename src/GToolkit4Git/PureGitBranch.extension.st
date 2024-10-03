Extension { #name : #PureGitBranch }

{ #category : #'*GToolkit4Git' }
PureGitBranch >> gtActionOperationsFor: composite [
	<gtAction>
	^ composite dropdown
		tooltip: 'Branch operations';
		icon: BrGlamorousVectorIcons hamburger;
		content: [ :aButton | BrGlamorousSimpleContextMenuContent new items: self gtOperations ]
]

{ #category : #'*GToolkit4Git' }
PureGitBranch >> gtDetails [
	^ super gtDetails , {
		{ 'branch name' . self name ifNil: [ '' ] . self name }.
		{ 'branch type' . self branchType }.
		{ 'commit' . self shortCommitId . self commit }
	}
]

{ #category : #'*GToolkit4Git' }
PureGitBranch >> gtOperations [
	^ #()
]
