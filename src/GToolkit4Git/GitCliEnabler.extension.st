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
			text: [ :each | each isGitCliRepository ifTrue: [ 'Libgit-CLI' ] ifFalse: [ 'Libgit2 FFI' ] ];
		contextItemLabel: 'Inspect IceRepository'
			action: [ :element :each | element phlow spawnObject: each ];
		contextItemLabel: 'Inspect GtGitRepository'
			action: [ :element :each | element phlow spawnObject: (GtGitRepository fromIcebergRepository: each) ];
		contextItemLabel: 'Inspect PureGitRepository'
			action: [ :element :each | element phlow spawnObject: (PureGitRepository on: each location) ];
		contextItemLabel: 'Open Git tool'
			action: [ :element :each | 
				element phlow
					spawnObject: (GtGitPhlowTool new repository: (GtGitRepository fromIcebergRepository: each)) ];
		updateWhen: IceAnnouncement , IceRepositoryRegistryModified in: Iceberg announcer;
		actionUpdateButton
]
