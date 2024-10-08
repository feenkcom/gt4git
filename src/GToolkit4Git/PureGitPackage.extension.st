Extension { #name : #PureGitPackage }

{ #category : #'*GToolkit4Git' }
PureGitPackage >> gtActionLoadFor: composite [
	<gtAction>
	^ composite button
		label: 'Load';
		priority: 20;
		tooltip: 'Read and load package from repository';
		action: [ self load ]
]

{ #category : #'*GToolkit4Git' }
PureGitPackage >> gtActionSaveFor: composite [
	<gtAction>
	^ composite button
		label: 'Save';
		priority: 25;
		tooltip: 'Write package to repository';
		action: [ self save ]
]

{ #category : #'*GToolkit4Git' }
PureGitPackage >> gtDetails [
	^ super gtDetails , {
		{ 'name' . self name }.
		{ 'loaded' . self isLoaded }.
		{ 'loaded commit'
			. self loadedCommitId ifNil: [ '' ].
			. self loadedCommit }.
		{ 'up to date' . self isUpToDate }.
	}
]

{ #category : #'*GToolkit4Git' }
PureGitPackage >> gtViewIncomingChangesFor: composite [
	<gtView>
	^ composite list
		title: 'Incoming';
		priority: 30;
		items: [ self incomingChanges operations ];
		actionUpdateButton
]

{ #category : #'*GToolkit4Git' }
PureGitPackage class >> gtViewLoadedCommitsFor: composite [
	<gtClassView>
	^ composite columnedList
		title: 'Loaded commits';
		priority: 40;
		items: [ self loadedCommits associations ];
		column: 'Package' text: #key;
		column: 'Commit' text: #value
]

{ #category : #'*GToolkit4Git' }
PureGitPackage >> gtViewOutgoingChangesFor: composite [
	<gtView>
	^ composite list
		title: 'Outgoing';
		priority: 35;
		items: [ self outgoingChanges operations ];
		actionUpdateButton
]
