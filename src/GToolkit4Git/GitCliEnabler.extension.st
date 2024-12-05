Extension { #name : #GitCliEnabler }

{ #category : #'*GToolkit4Git' }
GitCliEnabler >> gtActionRevertAllIn: composite [
	<gtAction>
	
	^ composite button
		label: 'Revert all';
		tooltip: 'Revert all repositories to the old Libgit2 FFI implementation';
		priority: 30;
		action: [ :element | self revertAll ]
]

{ #category : #'*GToolkit4Git' }
GitCliEnabler >> gtActionSwitchAllIn: composite [
	<gtAction>
	
	^ composite button
		label: 'Switch all';
		tooltip: 'Switch all repositories to the new Libgit-CLI implementation';
		priority: 20;
		action: [ :element | self switchAll ]
]

{ #category : #'*GToolkit4Git' }
GitCliEnabler >> gtViewRegistryIn: composite [
	<gtView>
	^ composite columnedList
		title: 'Registry';
		tooltip: 'Show registered repositories';
		priority: 40;
		items: [ IceRepository registry sorted: #name ascending ];
		column: 'Name' text: #name;
		column: 'Origin' text: [ :each | [ each originUrl ] on: Error do: [ '' ] ];
		column: 'Implementation'
			text: [ :each | 
				each isGitCliRepository
					ifTrue: [ 'Libgit-CLI' asRopedText foreground: Color blue ]
					ifFalse: [ 'Libgit2 FFI' asRopedText foreground: Color orange ] ];
		contextItemLabel: 'Inspect IceRepository'
			action: [ :element :repository | element phlow spawnObject: repository ];
		contextItemLabel: 'Inspect GtGitRepository'
			action: [ :element :repository | element phlow spawnObject: (GtGitRepository fromIcebergRepository: repository) ];
		contextItemLabel: 'Inspect PureGitRepository'
			action: [ :element :repository | element phlow spawnObject: (PureGitRepository on: repository location) ];
		contextItemLabel: 'Open Git tool'
			action: [ :element :repository | 
				element phlow
					spawnObject: (GtGitPhlowTool new repository: (GtGitRepository fromIcebergRepository: repository)) ];
		contextItemLabel: 'Switch Implementation'
			action: [ :element :repository | self switchRepositoryImplementation: repository ];
		updateWhen: IceAnnouncement , IceRepositoryRegistryModified
			in: Iceberg announcer;
		actionUpdateButton
]
