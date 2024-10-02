Extension { #name : #PureGitLocalBranch }

{ #category : #'*GToolkit4Git' }
PureGitLocalBranch >> gtDetails [
	^ super gtDetails , {
		{ 'current' . self isCurrent }.
		{ 'upstream' 
			. self upstream ifNil: [ '' ] ifNotNil: [ :branch | branch name ]
			. self upstream }.
	} 
]

{ #category : #'*GToolkit4Git' }
PureGitLocalBranch >> gtOperations [
	^ Array streamContents: [ :actions | 
		self isCurrent
			ifFalse: [ 
				actions nextPut: 'Checkout' -> [ :e | 
					self checkout.
					e fireEvent: BrDropdownHideWish new ] ].
		self isCurrent
			ifFalse: [
				actions nextPut: 'Merge' -> [ :e | 
					self merge.
					e fireEvent: BrDropdownHideWish new ] ].
		self hasUpstream
			ifTrue: [
				actions nextPut: 'Pull' -> [ :e |
					self pull.
					e fireEvent: BrDropdownHideWish new ].
				actions nextPut: 'Push' -> [ :e |
					self push.
					e fireEvent: BrDropdownHideWish new ].
				actions nextPut: 'Fetch' -> [ :e |
					self fetch.
					e fireEvent: BrDropdownHideWish new ] ].
		actions nextPut: 'Delete' -> [ :e | 
			e phlow spawnObject: 'Not yet implemented'.
			e fireEvent: BrDropdownHideWish new ] ]
]
