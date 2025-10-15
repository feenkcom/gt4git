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
		action: [ :aButton | aButton phlow spawnTool: (GtGitPhlowTool forClass: self) ];
		primaryModifierAction: [ :aButton | 
			BlSpace new
				withCommonSettings;
				inPager: [ GtGitPhlowTool forClass: self ];
				title: 'Git';
				icon: BrGlamorousVectorIcons branching;
				showFrom: aButton ]
]
