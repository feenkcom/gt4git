Extension { #name : #PureGitCodeRepository }

{ #category : #'*GToolkit4Git' }
PureGitCodeRepository >> gtDetails [
	^ super gtDetails , {
		{ 'src directory' . self srcDirectory }.
	}
]

{ #category : #'*GToolkit4Git' }
PureGitCodeRepository >> gtViewPackagesFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Packages';
		priority: 60;
		items: [ self packages ];
		column: 'Name' text: #name;
		column: 'Loaded' text: #isLoaded;
		updateWhen: PureGitRepositoryModified in: [ self announcer ];
		actionUpdateButton
]
