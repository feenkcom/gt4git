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
PureGitPackage >> gtActionSetLoadedCommitFor: composite [
	<gtAction>
	^ composite button
		label: 'Set';
		priority: 30;
		tooltip: 'Set package loaded commit to repository head';
		action: [
			self incomingChanges isEmpty
				ifTrue: [ self setLoadedCommit ]
				ifFalse: [ self error: 'Cannot set package loaded commit to repository head as there are incoming changes' ] ]
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
	^ composite forward
		title: 'Incoming';
		priority: 30;
		object: [ self incomingChanges ];
		view: #gtViewOperationsTreeIn:;
		actionUpdateButton;
		updateWhen: PureGitRepositoryModified in: [ self repository announcer ]
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
	^ composite forward
		title: 'Outgoing';
		priority: 35;
		object: [ self outgoingChanges ];
		view: #gtViewOperationsTreeIn:;
		actionUpdateButton;
		updateWhen: PureGitRepositoryModified in: [ self repository announcer ]
]
