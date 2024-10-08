Extension { #name : #PureGitPackage }

{ #category : #'*GToolkit4Git' }
PureGitPackage >> gtActionLoadFor: composite [
	<gtAction>
	^ composite button
		label: 'Load';
		priority: 20;
		action: [ self load ]
]

{ #category : #'*GToolkit4Git' }
PureGitPackage >> gtActionSaveFor: composite [
	<gtAction>
	^ composite button
		label: 'Save';
		priority: 25;
		action: [ self save ]
]

{ #category : #'*GToolkit4Git' }
PureGitPackage >> gtDetails [
	^ super gtDetails , {
		{ 'name' . self name }.
		{ 'loaded' . self isLoaded }.
	}
]
