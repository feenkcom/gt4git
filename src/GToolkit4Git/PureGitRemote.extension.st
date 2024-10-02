Extension { #name : #PureGitRemote }

{ #category : #'*GToolkit4Git' }
PureGitRemote >> gtActionOperationsFor: composite [
	<gtAction>
	^ composite dropdown
		tooltip: 'Repository operations';
		icon: BrGlamorousVectorIcons hamburger;
		content: [ :aButton | 
			BrGlamorousSimpleContextMenuContent new
				items: (Array streamContents: [ :actions |
					actions nextPut: 'Pull' -> [ :e |
						self pull.
						e fireEvent: BrDropdownHideWish new ].
					actions nextPut: 'Push' -> [ :e |
						self push.
						e fireEvent: BrDropdownHideWish new ].
					actions nextPut: 'Fetch' -> [ :e |
						self fetch.
						e fireEvent: BrDropdownHideWish new ] ]) ]
]

{ #category : #'*GToolkit4Git' }
PureGitRemote >> gtBranchesFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Branches';
		priority: 40;
		tooltip: 'Remote branches from this remote';
		items: [ self branches ];
		column: 'Name' text: #name;
		column: 'Type' text: #branchType;
		column: 'Commit' text: #shortCommitId
]

{ #category : #'*GToolkit4Git' }
PureGitRemote >> gtDetails [
	^ super gtDetails , {
		{ 'name' . self name }.
		{ 'url' . self url }
	}
]
