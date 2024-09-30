Extension { #name : #PureGitLocalBranch }

{ #category : #'*GToolkit4Git' }
PureGitLocalBranch >> gtActionOperationsFor: composite [
	<gtAction>
	^ composite dropdown
		tooltip: 'Branch operations';
		icon: BrGlamorousVectorIcons hamburger;
		content: [ :aButton | 
			BrGlamorousSimpleContextMenuContent new
				items: (Array streamContents: [ :actions |
					self isCurrent ifFalse: [
						actions nextPut: 'Checkout' -> [ :e | 
							self checkout.
							e fireEvent: BrDropdownHideWish new ] ].
					actions nextPut: 'Delete' -> [ :e | 
						e phlow spawnObject: 'Not yet implemented'.
						e fireEvent: BrDropdownHideWish new ] ]) ]
]

{ #category : #'*GToolkit4Git' }
PureGitLocalBranch >> gtDetails [
	^ super gtDetails , {
		{ 'current' . self isCurrent }.
		{ 'upstream' 
			. self upstream ifNil: [ '' ] ifNotNil: [ :branch | branch name ]
			. self upstream }.
	} 
]
