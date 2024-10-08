Extension { #name : #PureGitPackage }

{ #category : #'*GToolkit4Git' }
PureGitPackage >> gtActionLoadFor: composite [
	<gtAction>
	^ composite button
		label: 'Load';
		priority: 20;
		tooltip: 'Read and force load package from repository';
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
PureGitPackage >> gtViewOutgoingChangesFor: composite [
	<gtView>
	^ composite list
		title: 'Outgoing';
		priority: 35;
		items: [ self outgoingChanges operations ];
		actionUpdateButton
]
