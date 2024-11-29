Extension { #name : #PureGitLocalBranch }

{ #category : #'*GToolkit4Git' }
PureGitLocalBranch >> gtDetails [
	^ super gtDetails , {
		{ 'current' . self isCurrent gtColoredText . self isCurrent  }.
		{ 'upstream' 
			. self upstream ifNil: [ '' ] ifNotNil: [ :branch | branch name ]
			. self upstream }.
		{ 'commits ahead' . self commitsAhead }.
		{ 'commits behind' . self commitsBehind }.
	} 
]

{ #category : #'*GToolkit4Git' }
PureGitLocalBranch >> gtIncomingCommitsFor: composite [
	<gtView>
	^ (self gtLogViewFor: composite)
		title: 'Incoming';
		priority: 40;
		tooltip: 'Incoming commits from remote';
		items: [ self incomingCommits ]
]

{ #category : #'*GToolkit4Git' }
PureGitLocalBranch >> gtOperations [
	^ Array streamContents: [ :actions |
		self commitsAhead > 0
			ifTrue: [
				actions nextPut: 'Push' -> [ :e | 
					e phlow spawnObject: self push.
					e fireEvent: BrDropdownHideWish new ]].
		self isCurrent
			ifFalse: [ 
				actions nextPut: 'Checkout' -> [ :e | 
					e phlow spawnObject: self checkout.
					e fireEvent: BrDropdownHideWish new ] ].
		self isCurrent
			ifFalse: [
				actions nextPut: 'Merge' -> [ :e | 
					e phlow spawnObject: self merge.
					e fireEvent: BrDropdownHideWish new ] ] ]
]

{ #category : #'*GToolkit4Git' }
PureGitLocalBranch >> gtOutgoingCommitsFor: composite [
	<gtView>
	^ (self gtLogViewFor: composite)
		title: 'Outgoing';
		priority: 45;
		tooltip: 'Outgoing commits to remote';
		items: [ self outgoingCommits ]
]
