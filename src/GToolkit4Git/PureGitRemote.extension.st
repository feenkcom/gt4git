Extension { #name : #PureGitRemote }

{ #category : #'*GToolkit4Git' }
PureGitRemote >> gtBranchesFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Branches';
		priority: 40;
		items: [ self branches ];
		column: 'Name' text: #name;
		column: 'Type' text: #branchType;
		column: 'Commit' text: #shortCommitId
]

{ #category : #'*GToolkit4Git' }
PureGitRemote >> gtDetails [
	^ super gtDetails , {
		{ 'name' . self name }.
		{ 'url' . self url }
	}
]
