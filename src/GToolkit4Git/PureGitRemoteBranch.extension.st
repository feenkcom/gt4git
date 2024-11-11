Extension { #name : #PureGitRemoteBranch }

{ #category : #'*GToolkit4Git' }
PureGitRemoteBranch >> gtDetails [
	^ super gtDetails , {
		{ 'remote' . self remoteName . self remote }
	}
]

{ #category : #'*GToolkit4Git' }
PureGitRemoteBranch >> gtOperations [
	^ Array streamContents: [ :actions | 
		actions nextPut: 'Merge' -> [ :e | 
			e phlow spawnObject: self merge.
			e fireEvent: BrDropdownHideWish new ] ]
]

{ #category : #'*GToolkit4Git' }
PureGitRemoteBranch >> gtTrackersFor: composite [
	<gtView>
	^ composite columnedList
		title: 'Trackers';
		priority: 40;
		tooltip: 'Local branches for which I am the upstream';
		items: [ self trackers ];
		column: 'Name' text: #name;
		column: 'Type' text: #branchType;
		column: 'Commit' text: #shortCommitId
]
