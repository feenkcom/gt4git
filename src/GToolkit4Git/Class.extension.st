Extension { #name : #Class }

{ #category : #'*GToolkit4Git' }
Class >> gtCoderSidebarIndexGitFrom: aGtCoderClassesTreeElement [
	<gtCoderSidebarIndexOneSubjectContextMenuItem: 7>
	(self respondsTo: #repository) ifFalse: [ ^ nil ].
	
	^ BrMenuActionItem new
		id: GtCoderGitButtonId;
		icon: BrGlamorousVectorIcons branching
			label: 'Browse git repository'
			preview: self;
		action: [ :aButton | 
			| coder repository |
			repository := self repository.
			repository
				ifNil: [ aButton phlow
						spawnTool: (GtPhlowExplicitTool new
								stencil: [ GtGitAddToRepositoryElement new package: coder navigationModel selectedPackage ]) ]
				ifNotNil: [ aButton phlow
						spawnTool: (GtGitPhlowTool new repository: repository) ] ]
]
