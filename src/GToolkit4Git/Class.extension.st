Extension { #name : #Class }

{ #category : #'*GToolkit4Git' }
Class >> gtCoderSidebarIndexGitFor: anAction [
	<gtAction>
	(self respondsTo: #repository) ifFalse: [ ^ anAction noAction ].
	
	^ anAction button
		priority: 7;
		id: GtCoderGitButtonId;
		target: GtCoderClassTarget;
		icon: BrGlamorousVectorIcons branching;
		label: 'Browse git repository';
		menuItemPreview: self name;
		menuItemGroup: BrMenuItemGroupConfiguration default;
		action: [ :aButton | 
			| repository |
			repository := self repository.
			repository
				ifNil: [ aButton phlow
						spawnTool: (GtPhlowExplicitTool new
								name: 'git';
								stencil: [ GtGitAddToRepositoryElement new package: self package ]) ]
				ifNotNil: [ aButton phlow
						spawnTool: (GtGitPhlowTool new repository: repository) ] ]
]
